function clusters=load_partitions(session_dir, epoch_name, varargin)

disp('specification of fields is not yet supported, if you need it fix it!');
fields = {'id', 'time'};


tt_dirs = dir(fullfile(session_dir, 'epochs', epoch_name));
clusters = [];
n_clust = 0;

for i =1:length(tt_dirs)
    if tt_dirs(i).isdir && ~strcmp(tt_dirs(i).name, '.') && ~strcmp(tt_dirs(i).name, '..')
        disp(['Partitioning tertrode ', tt_dirs(i).name, ' into clusters']);
        clp = partition_tetrode(session_dir, epoch_name, tt_dirs(i).name);  
       
        for j = 1:length(clp)
           n_clust = n_clust+1; 
           clusters(n_clust).id = 1:length(clp(j).dat);
           clusters(n_clust).time = clp(j).dat(:,strcmp(clp(j).flds, 'time'))';
        end
    end
end

disp([num2str(n_clust), ' clusters loaded!']);
        
if ~exist('clusters')
    clusters = [];
end