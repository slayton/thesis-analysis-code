function autoClusterPCAExp(baseDir, nChan)


if ~exist(baseDir, 'dir')
    error('Dir %s does not exist', baseDir)
end


klustDir = fullfile(baseDir, 'kKlustPCA');

% if exist(klustDir, 'dir')
%     fprintf('Removing previously created dir: %s\n', klustDir);
%     rmdir(klustDir,'s');
% end

mkdir(klustDir);

ep = 'amprun';

if nargin == 1
    nChan = 1;
end

[data, ttList] = loadExpWaveforms_PCA(baseDir, ep, nChan);

%% Save a complete file

fprintf('Saving feature files... ');
for iTetrode = 1:numel(data)
       
    if isempty( data{iTetrode} )
        continue;
    end
    
    outData = data{iTetrode}(:,1:4)';
       
    featFile = fullfile( klustDir, sprintf('pca%d.fet.%d', nChan, iTetrode) );
    fid = fopen(featFile, 'w+');
    
    % Write the number of features
    fprintf(fid, '4\n');
    % Write the feature matrix
    fprintf(fid, '%3.4f\t%3.4f\t%3.4f\t%3.4f\n', outData);
    
    fclose(fid);
    fprintf('Saved: %s\n', featFile);
    
%     fprintf('%s:%d ', ttList{iTetrode}, iTetrode);
end
%%
curDir = pwd;
cd(klustDir);

fprintf('Clustering... ');
nFetFile = numel( dir( fullfile(klustDir, sprintf('pca%d.fet.*', nChan) ) ) );

parfor iTetrode = 1:nFetFile
 
    cmd = sprintf('~/src/clustering/kk2.0/KlustaKwik pca%d %d -Screen 0', nChan, iTetrode )
    system(cmd);
    
end
    
   
save('spike_file.mat', 'data')
save('ttMap.mat', 'ttList');

cd(curDir)

fprintf('DONE!\n');




