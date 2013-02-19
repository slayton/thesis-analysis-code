function save_pca_feature_files(baseDir)

if ~exist(baseDir, 'dir')
    error('Dir %s does not exist', baseDir)
end

klustDir = fullfile(baseDir, 'kKlust');
if ~exist(klustDir, 'dir')
    mkdir(klustDir);
end

spikesFile = fullfile(klustDir, 'spike_params_pca.mat');
if ~exist(spikesFile)
    fprintf('Spikes file does not exist, creating it\n');
    convert_tt_files(baseDir);
end

in = load(spikesFile);
pc = in.pc;

ttListFile = fullfile(klustDir, 'dataset_ttList.mat');
in = load(ttListFile);
ttList = in.ttList;

%% Save a complete file

% ttList = in.amp_names;

fprintf('Saving feature files:\n');
for iTetrode = 1:numel(pc)
       
    featFile = fullfile( klustDir, sprintf('pca.fet.%d', iTetrode) );
    fprintf('\t%s\n', featFile);

    d = pc{iTetrode};
    fprintf('%d\n', iTetrode);
    if isempty(d) || numel(d) == 0
        
        [s,w] = unix( sprintf('touch %s', featFile) );
        continue;
    
    else
        
        d = d(:,1:12)';
        % Open the file
        fid = fopen(featFile, 'w+');    
        % Write the number of features
        fprintf(fid, '4\n'); 
        % Write the feature matrix
        fprintf(fid, '%3.4f\t%3.4f\t%3.4f\t%3.4f%3.4f\t%3.4f\t%3.4f\t%3.4f%3.4f\t%3.4f\t%3.4f\t%3.4f\n', d);
        fclose(fid);
        
    end
    
end
fprintf('\n');

