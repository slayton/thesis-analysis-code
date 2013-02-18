function [id] = load_dataset_clusters(baseDir)

if nargin==1
    plot = 0;
end
klustDir = fullfile(baseDir, 'kKlust');

if ~exist(klustDir, 'dir')
    error('%s does not exist', klustDir);
end


in = load( fullfile(klustDir, 'ttMap.mat') );
nTT = numel(in.ttList);

clFiles = dir(fullfile(klustDir, 'pca.clu.*'));
if numel(clFiles)==0
    error('No cluster files found in %s', klustDir);
end

id = repmat({}, nTT, 1);
for i = 1:nTT
    clFile = fullfile( klustDir, sprintf('pca.clu.%d', i ));
    [~, clId] = load_cluster_file(clFile);
    id{i} = clId;
end

end