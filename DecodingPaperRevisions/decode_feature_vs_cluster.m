
function [P, E, input] = decode_feature_vs_cluster(baseDir, methods)
%% Load DATA

if nargin > 20000
    clear;
    baseDir = '/data/spl11/day13';
    methods = true(7,1);
elseif nargin == 1 || isempty(methods)
     methods = true(7,1);   
end

ep = 'amprun';


if ~exist(baseDir,'dir');
    error('Invalid directory specified');
end

if ~any( strcmp( load_epochs(baseDir), ep) )
    error('Invalid epoch specified');
end

input.description = baseDir;
input.methods = methods;

%%%%%%%%%%%% DECODING PARAMETERS %%%%%%%%%%%%
% ampMaxLR = .05;
pcaMaxLR = .05;
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
clPca4 = load_dataset_clusters(baseDir, 'pca');
clPca1 = load_dataset_clusters(baseDir, 'pca.solo');

[amp, pc] = load_dataset_features(baseDir);


% statsAmp = computeClusterStats(clAmp, amp);
statsPca4 = computeClusterStats(clPca4, pc, 1);
statsPca1 = computeClusterStats(clPca1, pc, 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   SETUP INPUTS FOR THE DECODER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% All Spikes grouped by tetrode
% amp = amp; % <--- Not required but AMP is the first input
fprintf('Preparing data for: Feature-All Spikes\n');

%%%%%%%%%%%%%%%%%%%%% PCA Clustered spikes
fprintf('Preparing data for:Identity Pca Sorted+/- Hash\n');

clPca4All = {};  % Clustered on PCA space + HASH
clPca4Sorted = {}; % Clustered on PCA space - HASH
ampClPca4 = {}; % Amplitudes of clustered spikes - HASH

for iTT = 1:numel(clPca4)
    
    nullIdx = true( size(amp{iTT}, 1), 1); 
    
    for iCl = 1:max(clPca4{iTT})
        
        if statsPca4(iTT).nSpike(iCl) >= minNSpike && statsPca4(iTT).lRatio(iCl) <= pcaMaxLR
            
            idx = iCl == clPca4{iTT};
            
            clPca4Sorted{end+1} = amp{iTT}(idx,:);
            clPca4All{end+1} = amp{iTT}(idx,:);
            
            nullIdx (idx) = false;

        end
    end
    
    clPca4All{end+1} = amp{iTT}(nullIdx,:);
    ampClPca4{end+1} = amp{iTT}(~nullIdx,:);
end

%%%%%%%%%%%%%%%%%%%%% PCA Clustered spikes
fprintf('Preparing data for:Identity Pca Sorted+/- Hash\n');

clPca1All = {};  % Clustered on PCA space + HASH
clPca1Sorted = {}; % Clustered on PCA space - HASH
ampClPca1 = {}; % Amplitudes of clustered spikes - HASH

for iTT = 1:numel(clPca1)
    
    nullIdx = true( size(amp{iTT}, 1), 1); 
    
    for iCl = 1:max(clPca1{iTT})
        
        if statsPca1(iTT).nSpike(iCl) >= minNSpike && statsPca1(iTT).lRatio(iCl) <= pcaMaxLR
            
            idx = iCl == clPca1{iTT};
            
            clPca1Sorted{end+1} = amp{iTT}(idx,:);
            clPca1All{end+1} = amp{iTT}(idx,:);
            
            nullIdx (idx) = false;

        end
    end
    
    clPca1All{end+1} = amp{iTT}(nullIdx,:);
    ampClPca1{end+1} = amp{iTT}(~nullIdx,:);
end


% %%%%%%%%%%%%%%%%%%%%% AMP Clustered spikes, grouped by Tetrode
% 
% ampClAmp = {};
% ampClPca = {};
% 
% fprintf('Preparing data for:Identity Amp Sorted+/- Hash\n');
% 
% clAmpSorted = {};
% clAmpAll = {};
% 
% for iTT = 1:numel(clAmp) % for each tt
%     
%     nullIdx = true( size(amp{iTT}, 1), 1); 
%     
%     for iCl = 1:max(clAmp{iTT}) % for each cluster    
%        
%         if statsAmp(iTT).nSpike(iCl) >= minNSpike && statsAmp(iTT).lRatio(iCl) <= ampMaxLR
%             
%             idx = iCl == clAmp{iTT};
%             
%             clAmpSorted{end+1} = amp{iTT}(idx,:);
%             clAmpAll{end+1} = amp{iTT}(idx,:);
%             
%             nullIdx (idx) = false;
% 
%         end
%     end
%     
%     clAmpAll{end+1} = amp{iTT}(nullIdx,:);
%     ampClAmp{end+1} = amp{iTT}(~nullIdx,:);
% end

% Configure Inputs
input.data{1} = amp;             % <- Feature decoding all spikes
input.data{2} = ampClPca4;       % <- Feature decoding PCA4 Sorted Spikes
input.data{3} = amp;             % <- Feature decoding all spikes - 1 Channel
input.data{4} = ampClPca1;       % <- Feature decoding PCA1 sorted Spikes
input.data{5} = clPca4All;       % <- Cluster decoding PCA4 Sorted + Hash
input.data{6} = clPca1Sorted;    % <- Cluster decoding PCA1 Sorted
input.data{7} = clPca1All;       % <- Cluster decoding PCA1 Sorted + Hash
input.data{8} = clPca1Sorted;    % <- Cluster decoding PCA1 Sorted

input.nSpike = cellfun(@sum, cellfun( @(x) (cellfun(@(y)(size(y,1)), x)), input.data,'uniformoutput', 0));


input.resp_col{1} = [1 2 3 4];
input.resp_col{2} = [1 2 3 4];
input.resp_col{3} = [1]
input.resp_col{4} = [1];
input.resp_col{5} = [];
input.resp_col{6} = [];
input.resp_col{7} = [];
input.resp_col{8} = [];


input.method{1} = 'F - All';
input.method{2} = 'F - Sorted:Pca4';
input.method{3} = 'F - Sorted:Pca1';
input.method{4} = 'I - Pca4+Hash';
input.method{5} = 'I - Pca4';
input.method{6} = 'I - Pca1+Hash';
input.method{7} = 'I - Pca1';

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
        
    if nargout > 1 || nargin > 2000
        [P{ii}, E(ii)] = z.compute(decodingSegments);
    else
        P{ii} = z.compute(decodingSegments);
    end
end
