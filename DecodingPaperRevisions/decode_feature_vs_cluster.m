
function [P, E, input] = decode_feature_vs_cluster(baseDir, nChan)
%% Load DATA

if nargin > 20000
    clear;
    baseDir = '/data/spl11/day13';
    nChan = 4;
end

ep = 'amprun';


if ~exist(baseDir,'dir');
    error('Invalid directory specified');
end

if ~any( strcmp( load_epochs(baseDir), ep) )
    error('Invalid epoch specified');
end

input.description = baseDir;
input.methods = nChan;

%%%%%%%%%%%% DECODING PARAMETERS %%%%%%%%%%%%
% ampMaxLR = .05;
pcaMaxLR = inf;
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
input.et = et( strcmp(en, ep), :);
clear en et;

% clAmp = load_dataset_clusters(baseDir, 'tt');
clId = load_dataset_clusters(baseDir, 'pca', nChan);

[amp, pc] = load_dataset_features(baseDir, nChan);

statsPca = computeClusterStats(clId, pc);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   SETUP INPUTS FOR THE DECODER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% All Spikes grouped by tetrode
% amp = amp; % <--- Not required but AMP is the first input
fprintf('Preparing data for: Feature-All Spikes\n');

%%%%%%%%%%%%%%%%%%%%% PCA Clustered spikes
fprintf('Preparing data for:Identity Pca Sorted+/- Hash\n');

cl = {};  % Clustered on PCA space + HASH


for iTT = 1:numel(clId)
    
    nullIdx = true( size(amp{iTT}, 1), 1); 
    
    for iCl = 1:max(clId{iTT}) % clId 1 is the noise cluster
        
%         if statsPca(iTT).nSpike(iCl) >= minNSpike && statsPca(iTT).lRatio(iCl) <= pcaMaxLR
            idx = iCl == clId{iTT};
            cl{end+1} = amp{iTT}(idx,:);
%             clPca4Sorted{end+1} = amp{iTT}(idx,:);
             nullIdx (idx) = false;
%         end
    end
    if nnz(nullIdx) > 0
        cl{end+1} = amp{iTT}(nullIdx,:);
    end
%     ampClPca4{end+1} = amp{iTT}(~nullIdx,:);
end


input.data{1} = amp;             % <- Feature decoding all spikes
% input.data{2} = ampClPca4;       % <- Feature decoding PCA4 Sorted Spikes
input.data{2} = cl;       % <- Cluster decoding PCA4 Sorted + Hash
% input.data{4} = clPca4Sorted;    % <- Cluster decoding PCA1 Sorted

input.nSpike = cellfun(@sum, cellfun( @(x) (cellfun(@(y)(size(y,1)), x)), input.data,'uniformoutput', 0));


input.resp_col{1} = 1:nChan;
% input.resp_col{2} = [1 2 3 4];
input.resp_col{2} = [];
% input.resp_col{4} = [];

input.method{1} = 'Feature';
% input.method{2} = 'F - Sorted:Pca4';
input.method{2} = 'Identity';
% input.method{4} = 'I - Pca4';

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
        
        st{jj} = d{jj}(:, nChan+1);
        sp{jj} = d{jj}(:, nChan+2); %interp1(stimTimestamp, stimulus, st{jj}, 'nearest');
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
        
    if nargout > 1 || nargin > 2000
        [P{ii}, E(ii)] = z.compute(decodingSegments);
    else
        P{ii} = z.compute(decodingSegments);
    end
end
