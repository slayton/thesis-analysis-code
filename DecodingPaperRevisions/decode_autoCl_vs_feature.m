
function [P, E, input] = decode_autoCl_vs_feature(baseDir, ep)
%% Load DATA

if nargin == 1
    ep = 'amprun';
end

if ~exist(baseDir,'dir');
    error('Invalid directory specified');
end

if ~any( strcmp( load_epochs(baseDir), ep) )
    error('Invalid epoch specified');
end

input.description = baseDir;
input.ep = ep;


%%%%%%%%%%%% DECODING PARAMETERS %%%%%%%%%%%%
maxLRatio = .05;
minNSpike = 50;
decodeDT = .25;
decodeDP = .1;
minVelocity = .15;
stimulusBandwidth = .1;
responseBandwidth = 30;
timeSplit = 0; % MUST BE 0 or 1


%%%%%%%%%%%%     LOADING DATA    %%%%%%%%%%%%
pos = load_exp_pos(baseDir, ep);

[en, et] = load_epochs(baseDir);
input.et = et( strcmp(en, input.ep), :);
clear en et;

[cl, data, ttList] = load_clusters_for_day(baseDir);
stats = computeClusterStats(baseDir);

clAmp = data;

% filter the spikes for only spikes that were clustered
for iTT = 1:numel(cl)
    idx = false( size( data{iTT}, 1),1);
    for iCl = 1:max(cl{iTT})
        if stats(iTT).nSpike(iCl) > minNSpike && stats(iTT).lRatio(iCl) <= maxLRatio
            idx = idx | iCl == cl{iTT};
        end
    end
    clAmp{iTT} = clAmp{iTT}(idx,:);
end
clAmp = clAmp( ~cellfun(@isempty, clAmp));

clust = {};
% Group the spikes by clusters instead of by tetrode
for iTT = 1:numel(cl)
    for iCl = 1:max(cl{iTT})
        if stats(iTT).nSpike(iCl) > minNSpike && stats(iTT).lRatio(iCl) <= maxLRatio
            idx = iCl == cl{iTT};
            clust{end+1} = data{iTT}(idx,:);
        end
    end
end
clear iCl iTT idx stats;

% Configure Inputs
input.data{1} = data;
input.data{2} = clAmp;
input.data{3} = clust;
input.data{4} = clust;
clear data clAmp clust cl;

input.resp_col{1} = [1 2 3 4];
input.resp_col{2} = [1 2 3 4];
input.resp_col{3} = [];
input.resp_col{4} = [1 2 3 4];

input.method{1} = 'All Spikes - Feature';
input.method{2} = 'Clustered Spikes - Feature';
input.method{3} = 'Cell Identity';
input.method{4} = 'Cell Identity + Feature';

%%%%%%%%%%%%%% Construct the Inputs for the Decoder %%%%%%%%%%%%%%
isMovingIdx = abs(pos.lv) > minVelocity;

stimTimestamp = pos.ts(isMovingIdx);
stimulus = pos.lp(isMovingIdx);
stimulus = stimulus(:);


tbins = input.et(1):decodeDT:input.et(2);
posGrid = min(pos.lp):decodeDP:max(pos.lp);



encodingSegments = [];
decodeSegments = [];

switch timeSplit
    case 0 % 1st vs 2nd half
        
        n = numel(tbins);
        splitIdx = ceil(n/2);
        
        encodingSegments = tbins( [1, splitIdx] );
        
        decodeSegments = tbins(splitIdx:end-1)';
        decodeSegments = [decodeSegments, decodeSegments +  decodeDT];
        
        decodeTS = mean(decodeSegments,2);
        runSeg = interp1(pos.ts, double(isMovingIdx), decodeTS, 'nearest');
        decodeSegments = decodeSegments( logical(runSeg),:);
        
        clear n splitIdx tbins;
        
    case 1 % every other timebin
        
    otherwise
        error('Invalid timeSplit, must by 0 or 1');
end

clear timeSplit minNSpike maxLRatio ttList isMovingIdx pos;

%% - Decode the position estimate

P = {};
clear E;

for ii = 1:numel(input.data)
    fprintf('Decoding %s data set: %s\n', baseDir, input.method{ii});
    
    clear z;
    
    d = input.data{ii};
    st = {};
    sp = {};
    fet = {};
    
    useFet = ~isempty( input.resp_col{ii} );
    
    % Structure inputs for the KDE_Decoder object
    for jj = 1:numel(d)
        st{jj} = d{jj}(:, 5);
        sp{jj} = interp1(stimTimestamp, stimulus, st{jj}, 'nearest');
        fet{jj} = d{jj}(:, input.resp_col{ii});
    end
    
    z = kde_decoder(stimTimestamp, stimulus, st, sp, fet, ...
        'encoding_segments', encodingSegments, ...
        'stimulus_variable_type', 'linear', ...
        'stimulus_grid', {posGrid}, ...
        'stimulus_kernel', 'gaussian', ...
        'stimulus_bandwidth', stimulusBandwidth, ...
        'response_variable_type', 'linear', ...
        'response_kernel', 'gaussian', ...
        'response_bandwidth', responseBandwidth, ...
        'rate_offset', .0001);
    
    %  if ~isnumeric(other{2}) || ndims(other{2})~=2 || size(other{2},1)~=numel(obj.training_time)
    
    [P{ii}, E(ii)] = z.compute(decodeSegments);
    
end
