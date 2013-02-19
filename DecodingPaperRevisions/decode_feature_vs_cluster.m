
function [P, E, input] = decode_feature_vs_cluster(baseDir, ep, methods)
%% Load DATA

if nargin > 20000
    clear;
    ep = 'amprun';
    baseDir = '/data/spl11/day13';
    methods = true(7,1);
elseif nargin == 1 || isempty(ep)
    ep = 'amprun';    
end

if nargin<3
    methods = true(7,1);
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
maxLRatio = .1;
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


clAmp = load_dataset_clusters(baseDir, 'tt');
clPca = load_dataset_clusters(baseDir, 'pca');
[amp, pc] = load_dataset_features(baseDir);


statsAmp = computeClusterStats(clAmp, amp);
statsPca = computeClusterStats(clPca, pc);
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   SETUP INPUTS FOR THE DECODER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% All Spikes grouped by tetrode
% amp = amp; % <--- Not required but AMP is the first input

%%%%%%%%%%%%%%%%%%%%% AMP Clustered spikes, grouped by Tetrode
ampClAmp = amp;
for iTT = 1:numel(clAmp)
    idx = false( size( amp{iTT}, 1),1);
    
    for iCl = 1:max(clAmp{iTT})
        if statsAmp(iTT).nSpike(iCl) > minNSpike && statsAmp(iTT).lRatio(iCl) <= maxLRatio
            idx = idx | iCl == clAmp{iTT};
        end
    end

    ampClAmp{iTT} = ampClAmp{iTT}(idx,:);
end
ampClAmp = ampClAmp( ~cellfun(@isempty, ampClAmp));

%%%%%%%%%%%%%%%%%%%%% PCA Clustered spikes, grouped by Tetrode
ampClPca = amp;
for iTT = 1:numel(clPca)
    idx = false( size( amp{iTT}, 1),1);
    
    for iCl = 1:max(clPca{iTT})
        if statsPca(iTT).nSpike(iCl) > minNSpike && statsPca(iTT).lRatio(iCl) <= maxLRatio
            idx = idx | iCl == clPca{iTT};
        end
    end

    ampClPca{iTT} = ampClPca{iTT}(idx,:);
end
ampClPca = ampClPca( ~cellfun(@isempty, ampClPca));


%%%%%%%%%%%%%%%%%%%%% AMP Clustered spikes, grouped by Clusters + HASH
clAmpAll = {};
for iTT = 1:numel(clAmp)
    for iCl = 1:max(clAmp{iTT})
        
        nullClIdx = true( size(amp{iTT}, 1),1);
        if statsAmp(iTT).nSpike(iCl) > minNSpike && statsAmp(iTT).lRatio(iCl) <= maxLRatio
            idx = iCl == clAmp{iTT};
            nullClIdx (idx) = false;
            clAmpAll{end+1} = amp{iTT}(idx,:);
        end
        
        clAmpAll{end+1} = amp{iTT}(nullClIdx,:);
        input.null{iTT} = amp{iTT}(nullClIdx,:);
        
    end
end

%%%%%%%%%%%%%%%%%%%%% AMP Clustered spikes, grouped by Clusters

clAmpSorted = {};
for iTT = 1:numel(clAmp)
    for iCl = 1:max(clAmp{iTT})
        
        nullClIdx = true( size(amp{iTT}, 1));
        if statsAmp(iTT).nSpike(iCl) > minNSpike && statsAmp(iTT).lRatio(iCl) <= maxLRatio
            
            idx = iCl == clAmp{iTT};
            nullClIdx (idx) = false;
            clAmpSorted{end+1} = amp{iTT}(idx,:);
            
        end
    end
end

%%%%%%%%%%%%%%%%%%%%% PCA Clustered spikes, grouped by Clusters + HASH
clPcaAll = {};
for iTT = 1:numel(clPca)
    for iCl = 1:max(clPca{iTT})
        
        nullClIdx = true( size(amp{iTT}, 1),1);
        if statsPca(iTT).nSpike(iCl) > minNSpike && statsPca(iTT).lRatio(iCl) <= maxLRatio
            idx = iCl == clPca{iTT};
            nullClIdx (idx) = false;
            clPcaAll{end+1} = amp{iTT}(idx,:);
        end
        
        clPcaAll{end+1} = amp{iTT}(nullClIdx,:);
        input.null{iTT} = amp{iTT}(nullClIdx,:);
        
    end
end

%%%%%%%%%%%%%%%%%%%%% PCA Clustered spikes, grouped by Clusters

clPcaSorted = {};
for iTT = 1:numel(clPca)
    for iCl = 1:max(clPca{iTT})
        
        nullClIdx = true( size(amp{iTT}, 1));
        if statsPca(iTT).nSpike(iCl) > minNSpike && statsPca(iTT).lRatio(iCl) <= maxLRatio
            
            idx = iCl == clPca{iTT};
            nullClIdx (idx) = false;
            clPcaSorted{end+1} = amp{iTT}(idx,:);
            
        end
    end
end

clear iCl iTT idx stats;

% Configure Inputs
input.data{1} = amp;            % <- Feature decoding all spikes
input.data{2} = ampClAmp;       % <- Feature decoding Amp Sorted Spikes
input.data{3} = ampClPca;       % <- Feature decoding PCA sorted Spikes
input.data{4} = clAmpAll;       % <- Cluster decoding Amp Sorted + Hash
input.data{5} = clAmpSorted;    % <- Cluster decoding Amp Sorted
input.data{6} = clPcaAll;       % <- Cluster decoding PCA Sorted + Hash
input.data{7} = clPcaSorted;    % <- Cluster decoding PCA Sorted

clear data clAmp clust cl;

input.resp_col{1} = [1 2 3 4];
input.resp_col{2} = [1 2 3 4];
input.resp_col{3} = [1 2 3 4];
input.resp_col{5} = [];
input.resp_col{6} = [];
input.resp_col{7} = [];


input.method{1} = 'F - All';
input.method{2} = 'F - Sorted:Amp';
input.method{3} = 'F - Sorted:Pca';
input.method{4} = 'I - Amp+Hash';
input.method{5} = 'I - Amp';
input.method{6} = 'I - Pca+Hash';
input.method{7} = 'I - Pca';

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
        
    if nargout > 1
        [P{ii}, E(ii)] = z.compute(decodingSegments);
    else
        P{ii} = z.compute(decodingSegments);
    end
end
