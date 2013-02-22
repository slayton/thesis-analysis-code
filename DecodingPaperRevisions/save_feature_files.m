function save_feature_files(baseDir, nChan)

if ~exist(baseDir, 'dir')
    error('Dir %s does not exist', baseDir)
end

klustDir = fullfile(baseDir, 'kKlust');
if ~exist(klustDir, 'dir')
    mkdir(klustDir);
end
 
if nargin == 1
    nChan = 4;
end

nPcaFeat = nChan * 3;

% spikesFile = fullfile(klustDir, 'spike_params.mat');
% if ~exist(spikesFile)
%     fprintf('Spikes file does not exist, creating it\n');
%     convert_tt_files(baseDir);
% end

dsetFile = sprintf('%s/dataset_%dch.mat', klustDir, nChan);
if ~exist(dsetFile, 'file')
    error('Required dataset file does not exist, run save_dataset_file.m first');
end

in = load(dsetFile, 'amp', 'pc');
spikeAmp = in.amp;
prinComp = in.pc;

sprintf('SpikeAmp size[%d %d], nChan %d\n', size( spikeAmp{1},1), size( spikeAmp{1},2), nChan);

%% Save a complete file

% ttList = in.amp_names;

fprintf('Saving feature files:\n');

ampFormat = repmat( '%3.4f\t', [1, nChan]);
ampFormat(end) = 'n'; % replace last tab with newline

pcaFormat = repmat( '%3.4f\t', [1, nPcaFeat]);
pcaFormat(end) = 'n'; % replace last tab with newline

for iTetrode = 1:numel(spikeAmp)
       
    ampFeatFile = sprintf('%s/amp.%dch.fet.%d', klustDir, nChan, iTetrode);
    pcaFeatFile = sprintf('%s/pca.%dch.fet.%d', klustDir, nChan, iTetrode);
    
    fprintf('\t%s', ampFeatFile);
    fprintf('\t%s\n', pcaFeatFile);

    sa = spikeAmp{iTetrode};
    pc = prinComp{iTetrode};
    
    if isempty(sa) || numel(sa) == 0 || isempty(pc) || numel(pc) == 0
        [s, w] = unix( sprintf('touch %s', ampFeatFile) );
        [s, w] = unix( sprintf('touch %s', pcaFeatFile) );
        continue;
    
    else
        
    % Write the amplitude feature file
    fid = fopen(ampFeatFile, 'w+');    
    fprintf(fid, '%d\n', nChan); 
    fprintf(fid, ampFormat, sa);
    fclose(fid);

    % Write the PCA feature file
    fid = fopen(pcaFeatFile, 'w+');
    fprintf(fid, '%d\n', nPcaFeat);
    fprintf(fid, pcaFormat, pc);
    fclose(fid);
        
    end
    
end
fprintf('\n');

