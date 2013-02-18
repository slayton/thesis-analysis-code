function transform_feature_files(baseDir)

if ~exist(baseDir, 'dir')
    error('Dir %s does not exist', baseDir)
end

klustDir = fullfile(baseDir, 'kKlust');
if ~exist(klustDir, 'dir')
    mkdir(klustDir);
end

spikesFile = fullfile(klustDir, 'spikes.mat');
if ~exist(spikesFile)
    fprintf('Spikes file does not exist, creating it\n');
    convert_tt_files(baseDir);
end

fetFiles = dir( fullfile(klustDir, 'tt.fet.*'));

if numel( fetFiles ) == 0
    write_feature_files(baseDir);
    fetFiles = dir( fullFile(klustDir, 'tt.fet.*'));
end

%% Save a complete file

% ttList = in.amp_names;

fprintf('Running PCA on feature files:\n');
for iTetrode = 1:numel(fetFiles)
    
    inFile = fetFiles(iTetrode).name;
    outFile = regexprep(fetFiles(iTetrode).name, 'tt.fet', 'tt.pca.fet');
    fprintf('\t%s/%s\t->\t%s\n', klustDir, inFile, outFile);
    
    data = importFeatureFile( fullfile(klustDir), inFile );
    size(data)
    
%     outData = data{iTetrode}(:,1:4)';
%        
%     featFile = fullfile( klustDir, sprintf('tt.fet.%d', iTetrode) );
%     fid = fopen(featFile, 'w+');
%     
%     % Write the number of features
%     fprintf(fid, '4\n'); 
%     % Write the feature matrix
%     fprintf(fid, '%3.4f\t%3.4f\t%3.4f\t%3.4f\n', outData);
%     
%     fclose(fid);
%     
%      fprintf('%s:%d ', ttList{iTetrode}, iTetrode);
end
fprintf('\n');

