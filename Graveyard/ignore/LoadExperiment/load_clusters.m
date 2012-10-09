function clusters=load_clusters(session_dir, epoch_name)
% clusters = LOAD_CLUSTERS(session_dir, epoch_name, position)
%   session_dir = '/home/user/data/animalID/SessionID'
%   epoch_name = Name of the epoch
%   position struct     Position:
%                           timestamp
%                           linear_position
%                           headpos
%
%   Function loads cluster files from disk, and checks for good_cells.mat
%   under the epoch directory. If the good_cells.mat file is older than any
%   of the cluster files then it is rewritten. This is done by the user
%   using a script called evaluate_place_cells which is invoked
%   automatically by this script.
%
%   returns a structure of clusters


n_clust = 0;

fields = {'id', 'time'};
tt_dirs = dir(fullfile(session_dir, 'epochs', epoch_name));
newest_date = 0;
clusters = struct;

for i =1:length(tt_dirs)
    if tt_dirs(i).isdir && ~strcmp(tt_dirs(i).name, '.') && ~strcmp(tt_dirs(i).name, '..')
        files = dir(fullfile(session_dir, 'epochs', epoch_name, tt_dirs(i).name, epoch_name));
        disp([epoch_name, ': Loading clusters from tetrode:', tt_dirs(i).name]);
        
        for j=1:length(files)
            file = files(j).name;
            if length(file)>2 && strcmp(file(1:2),'cl')
                n_clust = n_clust + 1;
                f = mwlopen(fullfile(session_dir, 'epochs', epoch_name, tt_dirs(i).name, epoch_name, file));
                data = load(f, fields);
                clusters(n_clust).id = data.id;
                clusters(n_clust).time = data.time;
                clusters(n_clust).path = fullfile(session_dir, 'epochs', epoch_name, tt_dirs(i).name);
                clusters(n_clust).clfile = [epoch_name, '/', file];
                clusters(n_clust).ttfile = [tt_dirs(i).name, '.tt'];
                clusters(n_clust).tetrode = tt_dirs(i).name;
                %[a clusters(n_clust).location] = load_source(session_dir, clusters(n_clust).tetrode);
                if files(j).datenum>newest_date
                    newest_date = files(j).datenum;
                end
                clusters(n_clust).load_window = @(varargin) load_time_window(clusters(n_clust).time, varargin{:});
                clusters(n_clust).load_waveform = @(varargin) load_waveform(clusters(n_clust).id);
            end
        end
    end
end


disp([epoch_name, ': ',num2str(length(clusters)), ' clusters loaded!']);



function times =  load_time_window(all_times, varargin)
    args = struct('time_window', [0 Inf]);
    args = parseArgsLite(varargin{:}, args);
    times = [];
    for i=1:size(args.time_window)
        times = [times, all_times(all_times>=args.time_window(i,1) & all_times<=args.time_window(i,2))];
    end
end

function  wave = load_waveform(file, varargin)
	warning('load_waveform not implemented');
    wave = nan;
end
end