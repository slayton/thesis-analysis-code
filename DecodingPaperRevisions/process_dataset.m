function process_dataset(baseDir, MIN_VEL, MIN_AMP, MIN_WIDTH)
%% Check input arguments
if ~ischar(baseDir) || ~exist(baseDir, 'dir')
    error('baseDir must be a string and valid directory');
end

if nargin < 2 || isempty(MIN_VEL)
    MIN_VEL = .1;   % 10 cm/sec
end
if nargin < 3 || isempty(MIN_AMP)
    MIN_AMP = 75;   % 75 uVolts
end
if nargin < 4 || isempty(MIN_WIDTH)
    MIN_WIDTH = 12; % 12 Samples
end

%% Start processing

klustDir = fullfile(baseDir, 'kKlust');
if ~exist(klustDir, 'dir');
    fprintf('Creating:%s\n', klustDir);
    mkdir(klustDir);
end

% If the dataset files don't exist then load the waveforms from the tt
% files, process the waveforms and then save the dataset files
if ~exist( fullfile(klustDir, 'dataset_4ch.mat'), 'file') || ...
  ~exist( fullfile(klustDir, 'dataset_1ch.mat'), 'file')

    % load the waveform files from disk
    [ts, wf, ttList] = load_all_tt_waveforms( baseDir );
 
    %Save dataset files
    create_dataset_file(baseDir, 4, ts, wf, ttList, MIN_VEL, MIN_AMP, MIN_WIDTH);
    create_dataset_file(baseDir, 1, ts, wf, ttList, MIN_VEL, MIN_AMP, MIN_WIDTH);
    
end

%Read the dataset files and save feature files
save_feature_files(baseDir, 4);
save_feature_files(baseDir, 1);

%Cluster the feature files
cluster_feature_files(baseDir, 'pca', 4);
cluster_feature_files(baseDir, 'pca', 1);
% cluster_feature_files(baseDir, 'amp', 4); %<--- Can cluster on AMPlitude TOO!

end