function [id, data, ttList] = load_clusters_for_day(baseDir)

if nargin==1
    plot = 0;
end

if ~exist(baseDir, 'dir')
    error('Dir %s does not exist', baseDir)
end


klustDir = fullfile(baseDir, 'kKlust');
if ~exist(klustDir, 'dir')
    convert_tt_files(baseDir);
end

spikesFile = fullfile(klustDir, 'spikes.mat');
if ~exist(spikesFile, 'file')
    convert_tt_files(baseDir);
end

data = load( fullfile(klustDir, 'spikes.mat'));
data = data.data;

ttList = load( fullfile(klustDir, 'ttMap.mat') );
ttList = ttList.ttList;

ttFiles = dir(fullfile(klustDir, '*.clu.*'));
if numel(ttFiles)==0
    cluster_feature_files(baseDir);
end

nAmp = numel(data);
% nTT = numel(ttFiles);
% fprintf('%d %d\n', nAmp, nTT);

id = {};

for iTetrode = 1:nAmp

        clFile = fullfile( klustDir, sprintf('tt.clu.%d', iTetrode ));
        [~, clId] = loadClusterIdentities(clFile);
        id{iTetrode} = clId;
end

end