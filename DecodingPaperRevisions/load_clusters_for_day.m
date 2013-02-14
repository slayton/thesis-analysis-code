function [id, data, ttList] = load_clusters_for_day(baseDir)

if nargin==1
    plot = 0;
end

if ~exist(baseDir, 'dir')
    error('Dir %s does not exist', baseDir)
end


klustDir = fullfile(baseDir, 'kKlust');
if ~exist(klustDir, 'dir')
    error('Dir %s does not exist, has autoCluster been run?', klustDir);
end

data = load( fullfile(klustDir, 'spike_file.mat'));
data = data.data;

ttList = load( fullfile(klustDir, 'ttMap.mat') );
ttList = ttList.ttList;


ttFiles = dir(fullfile(klustDir, '*.clu.*'));

% Sort the files so that the order is 1,2,...,10 rather than 1,10,2,...
names = {ttFiles.name};
fileNum = cellfun(@str2double, regexprep( names, 'tt.clu.', ''));
[~, fileOrder] = sort(fileNum);
ttFiles = ttFiles(fileOrder);


nAmp = numel(data);
nTT = numel(ttFiles);

if nAmp ~= nTT
    error('Invalid data, nAmp:%d ~= nTT:%d', nAmp, nTT)
end

id = {};

for iTetrode = 1:nTT

        clFile = fullfile( klustDir, ttFiles(iTetrode).name );
        [nCl, clId] = loadClusterIdentities(clFile);
        id{iTetrode} = clId;
end



end