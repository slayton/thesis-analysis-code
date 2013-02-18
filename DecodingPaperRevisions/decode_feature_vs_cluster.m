
function [P, E, input] = decode_feature_vs_cluster(baseDir, ep, methods)
%% Load DATA

if nargin == 1 || isempty(ep)
    ep = 'amprun';
elseif nargin > 20000
    ep = 'amprun';
    baseDir = '/data/spl11/day14';
end

if nargin<3
    methods = true(4,1);
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
maxLRatio = Inf;
minNSpike = 0;
decodeDT = .25;
decodeDP = .1;
minVelocity = .15;
stimulusBandwidth = .1;
responseBandwidth = 30;
timeSplit = 0; % MUST BE 0 or 1

%%%%%%%%%%%%     LOAD THE DATA    %%%%%%%%%%%%

pos = load_exp_pos(baseDir, ep);

[en, et] = load_epochs(baseDir);
input.et = et( strcmp(en, input.ep), :);
clear en et;

cl = load_dataset_clusters(baseDir);
amp = load_dataset_features(baseDir);
pc = load_dataset_pca_features(baseDir);

stats = computeClusterStats(cl,amp);

ampSorted = amp;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SORTED spikes grouped by TETRODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for iTT = 1:numel(cl)
    idx = false( size( amp{iTT}, 1),1);
    
    for iCl = 1:max(cl{iTT})
        if stats(iTT).nSpike(iCl) > minNSpike && stats(iTT).lRatio(iCl) <= maxLRatio
            idx = idx | iCl == cl{iTT};
        end
    end

    ampSorted{iTT} = ampSorted{iTT}(idx,:);
end
ampSorted = ampSorted( ~cellfun(@isempty, ampSorted));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SORTED spikes grouped by CLUSTER + HASH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clAll = {};
for iTT = 1:numel(cl)
    for iCl = 1:max(cl{iTT})
        
        nullClIdx = true( size(amp{iTT}, 1),1);
        if stats(iTT).nSpike(iCl) > minNSpike && stats(iTT).lRatio(iCl) <= maxLRatio
            idx = iCl == cl{iTT};
            nullClIdx (idx) = false;
            clAll{end+1} = amp{iTT}(idx,:);
        end
        clAll{end+1} = amp{iTT}(nullClIdx,:);
        input.null{iTT} = amp{iTT}(nullClIdx,:);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SORTED spikes grouped by CLUSTER - HASH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clSorted = {};
for iTT = 1:numel(cl)
    for iCl = 1:max(cl{iTT})
        
        nullClIdx = true( size(amp{iTT}, 1));
        if stats(iTT).nSpike(iCl) > minNSpike && stats(iTT).lRatio(iCl) <= maxLRatio
            
            idx = iCl == cl{iTT};
            nullClIdx (idx) = false;
            clSorted{end+1} = amp{iTT}(idx,:);
        end
    end
end

clear iCl iTT idx stats;

% Configure Inputs
input.data{1} = amp;
input.data{2} = ampSorted;
input.data{3} = clAll;
input.data{4} = clSorted;
clear data clAmp clust cl;

input.resp_col{1} = [1 2 3 4];
input.resp_col{2} = [1 2 3 4];
input.resp_col{3} = [];
input.resp_col{4} = [];

input.method{1} = 'Feature - All';
input.method{2} = 'Feature - Sorted';
input.method{3} = 'Identity - All';
input.method{4} = 'Identity - Sorted';

%%%%%%%%%%%%%% Construct the Inputs for the Decoder %%%%%%%%%%%%%%
isMovingIdx = abs(pos.lv) > minVelocity;

stimTimestamp = pos.ts(isMovingIdx);
stimulus = pos.lp(isMovingIdx);
stimulus = stimulus(:);

badIdx = isnan(stimulus);
stimulus = stimulus(~badIdx);
stimTimestamp = stimTimestamp(~badIdx);

tbins = (input.et(1):decodeDT:input.et(2)-decodeDT);
tbins = tbins( tbins >= stimTimestamp(1) & tbins <=stimTimestamp(end)-decodeDT);

tbins = [tbins', tbins'+decodeDT];
isMovingIdx = logical( interp1(pos.ts, double(isMovingIdx), mean(tbins,2), 'nearest') );

tbins = tbins(isMovingIdx, :);


posGrid = min(pos.lp):decodeDP:max(pos.lp);

encodingSegments = [];
decodingSegments = [];

switch timeSplit
    case 0 % 1st vs 2nd half
        
        n = size(tbins,1);
        splitIdx = ceil(n/2);
        
        encodingSegments = tbins(1:splitIdx,:);
        decodingSegments = tbins(splitIdx:end,:);

    case 1 % every other timebin
        n = numel(tbins);
        encodingSegments = tbins( 1:2:n, : );
        decodingSegments = tbins( 2:2:n, : );
        
    otherwise
        error('Invalid timeSplit, must by 0 or 1');
end

%% - Decode the position estimate

P = {};
clear E;

for ii = 1:numel(input.data)
   
    if ~methods(ii)
        fprintf('Skipping %s:%s --- %s\n', baseDir, ep, input.method{ii});
        continue;
    end
    fprintf('Decoding %s:%s --- %s\n', baseDir, ep, input.method{ii});
    
    clear z;
    
    d = input.data{ii};
    st = {}; % Spike Timestamp
    sp = {}; % Spike Position
    sf = {}; % Spike Features
    
    % Structure inputs for the KDE_Decoder object
    

    emptyIdx = false(numel(d),1);
    for jj = 1:numel(d)
      
        if numel(d{jj}) == 0
            emptyIdx(jj) = true;
            continue;
        end
        
        st{jj} = d{jj}(:, 5);
        sp{jj} = d{jj}(:, 6); %interp1(stimTimestamp, stimulus, st{jj}, 'nearest');
        sf{jj} = d{jj}(:, input.resp_col{ii});
        
        emptyIdx(jj) = nnz( inseg( encodingSegments, st{jj} ) ) < 1 || nnz( inseg( decodingSegments, st{jj} ) ) < 1;
 
    end
    
    st = st(~emptyIdx);
    sp = sp(~emptyIdx);
    sf = sf(~emptyIdx);
    
    z = kde_decoder(stimTimestamp, stimulus, st, sp, sf, ...
        'encoding_segments', encodingSegments, ...
        'stimulus_variable_type', 'linear', ...
        'stimulus_grid', {posGrid}, ...
        'stimulus_kernel', 'gaussian', ...
        'stimulus_bandwidth', stimulusBandwidth, ...
        'response_variable_type', 'linear', ...
        'response_kernel', 'gaussian', ...
        'response_bandwidth', responseBandwidth );
    
    %  if ~isnumeric(other{2}) || ndims(other{2})~=2 || size(other{2},1)~=numel(obj.training_time)
    
    if nargout > 1
        [P{ii}, E(ii)] = z.compute(decodingSegments);
    else
        P{ii} = z.compute(decodingSegments);
    end
end
