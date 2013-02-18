function cluster_feature_files(baseDir)

klustDir = fullfile(baseDir, 'kKlust');
if ~exist(klustDir, 'dir');
    write_feature_files(baseDir);
end

curDir = pwd;
cd(klustDir);


fprintf('Clustering... ');
nFetFile = numel( dir( fullfile(klustDir, 'tt.pca.fet.*')) );

if nFetFile==0
    error('No feature files found, have you called:save_pca_feature_files.m?');
end

parfor iTetrode = 1:nFetFile
 
    cmd = sprintf('~/src/clustering/kk2.0/KlustaKwik tt %d -Screen 0 -Log 0', iTetrode )
    system(cmd);
    
end  

cd(curDir)

fprintf('DONE!\n');
