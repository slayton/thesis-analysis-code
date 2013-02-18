function process_data_set(baseDir)

if ~exist(baseDir, 'dir')
    error('%s does not exist!\n', baseDir);
end


klustDir = fullfile(baseDir, 'kKlust');

% Create kKlust directory
if ~exist(klustDir);
    fprintf('Creating:%s\n', klustDir);
    mkdir(klustDir);
end


% load .tt files and save s spikes.mat and waveforms.mat
if ~exist( fullfile(klustDir, 'spikes.mat'), 'file') || ~exist( fullfile(klustDir, 'waveforms.mat'))
    save_waveform_files(baseDir);
else
    fprintf('spike.mat and waveforms.mat already saved, skipping\n');
end

featFiles = dir( fullfile(klustDir, 'tt.fet.*') );
if numel(featFiles) == 0
    save_feature_files(baseDir);
else
    fprintf('Feature files already saved, skipping\n');
end


pcaFiles = dir( fullfile(klustDir, 'tt.pca.fet.*') );
if numel(pcaFiles) == 0
    save_pca_feature_files(baseDir);
else
    fprintf('PCA feature files already saved, skipping\n');
end


clFiles = dir( fullfile(klustdir', 'tt.pca.clu.*' ));
if numel(clFiles) == 0
    cluster_feature_files(baseDir, 'tt.pca.clu');
else
    fprintf('PCA clusters already saved, skipping\n');
end



    



end