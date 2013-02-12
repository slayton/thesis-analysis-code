%% Load the data
clear;
baseDir = '/data/spl11/day15'; 
klustDir = fullfile(baseDir, 'kKlust');
if ~exist(klustDir, 'dir')
    mkdir(klustDir);
end

ep = 'amprun';

exp_in = exp_load(baseDir, 'epochs', ep, 'data_types', {'pos'});
in = setup_decoding_inputs(exp_in, ep);
%%

data = in.raw_amps;

data = select_amps_by_feature(data, 'feature', 'col', 'col_num', 8, 'range', [18 40]);
data = select_amps_by_feature(data, 'feature', 'amplitude', 'range', [125 inf]);
data = select_amps_by_feature(data, 'feature', 'col',   'col_num', 7, 'range', [.05 Inf]);

%% Save a complete file

ttList = [];
for iTetrode = 1:numel(data)
    ttList(iTetrode) = str2double( in.amp_names{iTetrode}(2:end));
end
%%
for iTetrode = 1:numel(data)
    
    featFile = fullfile( klustDir, sprintf('tt.fet.%d', ttList(iTetrode)) );
    fid = fopen(featFile, 'w+');
    
    outData = data{iTetrode}(:,1:4)';
    fprintf(fid, '4\n');
    fprintf(fid, '%3.4f\t%3.4f\t%3.4f\t%3.4f\n', outData);
    fclose(fid);
    fprintf('Saved %s\n', featFile);
    
end
%%
curDir = pwd;
cd(klustDir);

fprintf('Clustering!\n');
parfor iTetrode = 1:numel(ttList)
    tt = ttList(iTetrode);
    cmd = sprintf('~/src/clustering/kk2.0/KlustaKwik tt %d -Screen 0', tt )
    fprintf('%s\n',cmd);
    system(cmd);
end
fprintf('DONE!\n');
   
cd(curDir)


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            LOAD the clustered data from DISK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for iTetrode = 1:numel(ttList)

    clFile = fullfile( klustDir, sprintf('tt.clu.%d', ttList(iTetrode)) );
    [nCl, clId] = loadClusterIdentities(clFile);

    amp = data{iTetrode};
    
    figure('Name', sprintf('tt%d', ttList(iTetrode)), 'Position', [70 675 560 420] + iTetrode * [20 -20 0 0 ]);    
    cmap = colormap('jet'); 
    c = interp1(1:size(cmap,1), cmap, linspace(1, size(cmap,1), nCl), 'nearest');

    
    for iCluster = 1:nCl
        idx = clId == iCluster;
        
        line(amp(idx,1), amp(idx,2), amp(idx,3),'color', c(iCluster,:), 'marker', '.', 'linestyle', 'none');        
        
    end
    drawnow;
end





