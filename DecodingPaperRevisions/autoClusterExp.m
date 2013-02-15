function autoClusterExp(baseDir, plot)

if nargin==1
    plot = 0;
end

if ~exist(baseDir, 'dir')
    error('Dir %s does not exist', baseDir)
end


klustDir = fullfile(baseDir, 'kKlust');
if exist(klustDir, 'dir')
    fprintf('Removing previously created dir: %s\n', klustDir);
    rmdir(klustDir,'s');
end
mkdir(klustDir);

ep = 'amprun';

exp_in = exp_load(baseDir, 'epochs', ep, 'data_types', {'pos'});
in = setup_decoding_inputs(exp_in, ep);
%%

data = in.raw_amps;

data = select_amps_by_feature(data, 'feature', 'col', 'col_num', 8, 'range', [12 40]);
data = select_amps_by_feature(data, 'feature', 'amplitude', 'range', [125 inf]);
data = select_amps_by_feature(data, 'feature', 'col',   'col_num', 7, 'range', [.15 Inf]);

%% Save a complete file

ttList = in.amp_names;

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
    
%     fprintf('%s:%d ', ttList{iTetrode}, iTetrode);
end
%%
curDir = pwd;
cd(klustDir);

fprintf('Clustering... ');
nFetFile = numel( dir( fullfile(klustDir, 'tt.fet.*')) );

parfor iTetrode = 1:nFetFile
 
    cmd = sprintf('~/src/clustering/kk2.0/KlustaKwik tt %d -Screen 0', iTetrode )
    system(cmd);
    
end
    
   
save('spike_file.mat', 'data')
save('ttMap.mat', 'ttList');

cd(curDir)

fprintf('DONE!\n');


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            LOAD the clustered data from DISK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if plot==1
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
end





