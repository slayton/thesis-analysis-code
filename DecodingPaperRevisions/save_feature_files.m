function save_feature_files(baseDir, nChan)

%% Check input arguments
if ~ischar(baseDir) || ~exist(baseDir, 'dir')
    error('baseDir must a string and valid directory');
end

if ~isnumeric(nChan) || ~isscalar(nChan) || ~inrange(nChan, [1 4])
    error('nChan must be a numberic scalar between 1 and 4');
end

klustDir = fullfile(baseDir, 'kKlust');
if ~exist(klustDir, 'dir')
    mkdir(klustDir);
end


%% Load the dataset file
nPcaFeat = nChan * 3;

dsetFile = sprintf('%s/dataset_%dch.mat', klustDir, nChan);
if ~exist(dsetFile, 'file')
    error('Required dataset file not found, has save_dataset_file been called?');
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
%         [s, w] = unix( sprintf('touch %s', ampFeatFile) );
        [s, w] = unix( sprintf('touch %s', pcaFeatFile) );
        continue;
    
    else

% Uncomment to create spike amplitude feature files
%     % Write the AMP feature file
%     fid = fopen(ampFeatFile, 'w+');    
%     fprintf(fid, '%d\n', nChan); 
%     fprintf(fid, ampFormat, sa);
%     fclose(fid);

    % Write the PCA feature file
    fid = fopen(pcaFeatFile, 'w+');
    fprintf(fid, '%d\n', nPcaFeat);
    fprintf(fid, pcaFormat, pc);
    fclose(fid);
        
    end
    
end
fprintf('\n');

