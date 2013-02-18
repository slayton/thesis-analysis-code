function write_feature_files(baseDir)

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

in = load(spikesFile);
data = in.data;

ttMap = fullfile(klustDir, 'ttMap.mat');
in = load(ttMap);
ttList = in.ttList;

%% Save a complete file

% ttList = in.amp_names;

fprintf('Saving feature files... ');
for iTetrode = 1:numel(data)
       
    outData = data{iTetrode}(:,1:4)';
       
    featFile = fullfile( klustDir, sprintf('tt.fet.%d', iTetrode) );
    fid = fopen(featFile, 'w+');
    
    % Write the number of features
    fprintf(fid, '4\n'); 
    % Write the feature matrix
    fprintf(fid, '%3.4f\t%3.4f\t%3.4f\t%3.4f\n', outData);
    
    fclose(fid);
    
     fprintf('%s:%d ', ttList{iTetrode}, iTetrode);
end
fprintf('\n');

