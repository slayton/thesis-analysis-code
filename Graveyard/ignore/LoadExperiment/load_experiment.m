function exp = load_experiment(session_dir, varargin)
%LOAD_EXPERIMENT loads an exp struct from disk using import_experiment_data
% and then does some processing on it. It then runs preprocess_experiment.m
% on this structure and performs all computations done by that function.
%
% exp=LOAD_EXPERIMENT(session_dir) loads all data types from all epochs
% stored under session_dir
%
% exp=LOAD_EXPERIMENT(..., 'epochs', {epoch_list}, ...) only loads from epochs
% contained in epoch_list
%
% exp=LOAD_EXPERIMENT(..., 'data_types', {type_list}, ...) only loads
% specific data types. Valid data types are: clusters, eeg, multi-unit, position
%
% exp=LOAD_EXPERIMENT(..., 'operations', {operation_list}, ...)  specifies
% a specific set of operations to run on the data. For a full set of
% operations consult the documentation for process_experiment
% 
% See also import_experiment, process_experiment

en = load_epochs(fullfile(session_dir, 'epochs'))

args.data_types = {'clusters', 'eeg', 'multi-unit', 'position'};
args.epochs = en;
args.operations = ...
    {'calc_tc', 'calc_mub','calc_rip_burst', 'filt_clusters',...
    'filt_eeg', 'sort_clusters', 'cluster_stats'};


args = parseArgs(varargin, args);

exp = import_experiment(session_dir,...
    'epochs', args.epochs, 'data_types', args.data_types);

exp = process_experiment(exp, 'operations', args.operations );

end
