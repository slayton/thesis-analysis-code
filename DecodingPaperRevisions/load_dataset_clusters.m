function [id] = load_dataset_clusters(baseDir, prefix)


klustDir = fullfile(baseDir, 'kKlust');
fprintf('Loading clusters: %s\n', klustDir);

if nargin==1 || isempty(prefix) || ~ischar(prefix)
    prefix = 'tt';
end

if ~any(strcmp(prefix, {'tt', 'pca'}))
    error('Invalid cluster file prefix:%s', prefix);
end

in = load( fullfile(klustDir, 'dataset_ttList.mat') );
nTT = numel(in.ttList);

id = repmat({}, nTT, 1);

for i = 1:nTT
    clFile = fullfile( klustDir, sprintf('%s.clu.%d', prefix, i ));
    clId = load_cluster_file(clFile);
    id{i} = clId;
end

end