function process_dataset(baseDir)

MIN_VEL = .05;
MIN_AMP =  75;

if ~exist(baseDir, 'dir')
    error('%s does not exist!\n', baseDir);
end

klustDir = fullfile(baseDir, 'kKlust');

% Create kKlust directory
if ~exist(klustDir, 'dir');
    fprintf('Creating:%s\n', klustDir);
    mkdir(klustDir);
    
end


if ~exist( fullfile(klustDir, 'dataset_ts.mat'), 'file')    
    save_dataset_waveforms(baseDir);
end

process_dataset_waveform_file(baseDir, MIN_VEL, MIN_AMP);    

save_feature_files(baseDir);
save_pca_feature_files(baseDir);

cluster_feature_files(baseDir);
cluster_feature_files(baseDir, 'pca');




    



end