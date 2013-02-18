function save_pca_feature_files(baseDir)

if ~exist(baseDir, 'dir')
    error('Dir %s does not exist', baseDir)
end

klustDir = fullfile(baseDir, 'kKlust');
if ~exist(klustDir, 'dir')
    error('%s does not exist!', klustDir);
end

waveFile = fullfile(klustDir, 'waveforms.mat');

if ~exist(waveFile)
    fprintf('Spikes file does not exist, creating it\n');
    save_tt_waveforms(baseDir);
end

waveform = load(waveFile);
waveform = waveform.waveform;

nTT = numel(waveform);
nChan = size(waveform{1},1);

pcaFeatures = {};

fprintf('Computing pca waveform features\n');
for iTT = 1:nTT
    
    d = [];
    wf = waveform{iTT};
    
    if isempty(wf)
        pcaFeatures{iTT} = [];
        continue;
    end
    
    for iChan = 1:nChan
        w = squeeze(waveform{iTT}(iChan,:,:))';
        
        [~, s] = pca(w, 'NumComponents', 3);
        d = [d, s];
        
    end
    pcaFeatures{iTT} = d;
end

%% Save a complete file

% ttList = in.amp_names;

fprintf('Saving pca feature files:\n');
for iTetrode = 1:numel(pcaFeatures)
    
    pcaFile = sprintf('%s/%s%d', klustDir, 'tt.pca.fet.', iTetrode);
    fprintf('\t%s\n', pcaFile);
    
    data = pcaFeatures{iTetrode};
    
    % Open the file
    fid = fopen(pcaFile, 'w+');
    % Write the number of features
    fprintf(fid, '12\n');
    % Write the feature matrix
    fprintf(fid, '%3.4f\t%3.4f\t%3.4f\t%3.4f\t%3.4f\t%3.4f\t%3.4f\t%3.4f\t%3.4f\t%3.4f\t%3.4f\t%3.4f\n', data);
    fclose(fid);
    
end
fprintf('\n');

