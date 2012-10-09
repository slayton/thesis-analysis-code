function exp = import_experiment(session_dir, varargin)
%IMPORT_EXPERIMENT creates and exp struct from MWL-AD data stored on the disk
%
% exp=IMPORT_EXPERIMENT(session_dir) loads all data types from all epochs
% stored under session_dir
%
% exp=IMPORT_EXPERIMENT(..., 'epochs', {epoch_list}, ...) only loads from epochs
% contained in epoch_list
%
% exp=IMPORT_EXPERIMENT(..., 'data_types', {data_type_list}) only loads
% specific data types. Valid data types are: clusters, eeg, multi-unit, position
%
% exp=IMPORT_EXPERIMENT(..., 'force_pos', 1) forces recreation of the
% linear_position file

exp = [];
%% Experiment Meta DAta
exp.date_loaded = date;
exp.session_dir = session_dir;



%% Experiment Epoch List
[en et] = load_epochs(fullfile(session_dir, 'epochs'));
args.epochs = en;
args.data_types = {'eeg', 'clusters', 'position', 'multi-unit', 'meta'};


args = parseArgs(varargin, args);

exp.epochs = args.epochs;


disp(['Loading the following epochs:',cell2str(args.epochs)]);
disp(['Loading the following data types:', cell2str(args.data_types)]);
for e = args.epochs
    e = e{:};
    exp.(e) = struct;
    exp.(e).epoch_times = et(ismember(en, e),:);
    

    %% Load Clusters
    if ismember('clusters', args.data_types)
        exp.(e).clusters = load_clusters(session_dir, e);
        exp.(e).clusters = orderfields(exp.(e).clusters);
    end
    %% Load EEG
    if ismember('eeg', args.data_types)
        [exp.(e).eeg exp.(e).eeg_ts] = load_eeg(session_dir, e, 'n_chan', 8);
        exp.(e).eeg = orderfields(exp.(e).eeg);

    end
    %% Load Multi-Unit
    if ismember('multi-unit', args.data_types)
        mu = load_multiunit(session_dir, e);
        mu_bw = .01;
        mu_smooth_std = .01;
        
        exp.(e).multiunit.spike_times=mu;
        exp.(e).multiunit.timestamps = exp.(e).epoch_times(1):mu_bw:exp.(e).epoch_times(2);
        exp.(e).multiunit.spike_times = unique(exp.(e).multiunit.spike_times);
        exp.(e).multiunit.rate = single( smoothn( ....
            histc( exp.(e).multiunit.spike_times,  exp.(e).multiunit.timestamps),...
            mu_smooth_std, mu_bw ) );
        exp.(e).multiunit = orderfields(exp.(e).multiunit);
        
    end
    %% Load Position
    if ismember('position', args.data_types)
        if exist(fullfile(session_dir, 'epochs', e, 'lin_pos.p'), 'file')
            exp.(e).position = load_position(session_dir, e);
        elseif exist(fullfile(session_dir, 'epochs', e, 'linear_position.p'), 'file')           
            exp.(e).position = load_position_old(session_dir, e);
        else
            exp.(e).position = load_position(session_dir,e);
        end
        exp.(e).position = orderfields(exp.(e).position);

    end
    exp.(e) = orderfields(exp.(e));
      
    
    
end
%% Load Meta Data
if ismember('meta', args.data_types)
    load_experiment_meta_data(session_dir);
end


end