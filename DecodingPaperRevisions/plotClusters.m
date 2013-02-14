function plotClusters(baseDir)

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
size(data)

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

for iTetrode = 1:nTT

        clFile = fullfile( klustDir, ttFiles(iTetrode).name );
        [nCl, clId] = loadClusterIdentities(clFile);

        amp = data{iTetrode};

        figure('Name', sprintf('%s - %s', baseDir, ttList{iTetrode}), 'Position', [70 675 560 420] + iTetrode * [30 -30 0 0 ]);    
        axes('Color', 'k');
        cmap = colormap('jet'); 
        c = interp1(1:size(cmap,1), cmap, linspace(1, size(cmap,1), nCl), 'nearest');
        
        for iCluster = 1:nCl
            idx = clId == iCluster;

            line(amp(idx,1), amp(idx,2), amp(idx,3),'color', c(iCluster,:), 'marker', '.', 'linestyle', 'none', 'markersize', 1);        

        end
        
        pause(.01);
 end


end