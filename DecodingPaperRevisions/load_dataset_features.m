function [amp, pc] = load_dataset_features(baseDir)

if nargin==1
    plot = 0;
end

klustDir = fullfile(baseDir, 'kKlust');


spFile = fullfile(klustDir, 'spike_params.mat');
pcFile = fullfile(klustDir, 'spike_params_pca.mat');

if ~exist(spFile, 'file')
    error('%s does not exist', spFile);
end

if ~exist(pcFile, 'file')
    error('%s does not exist', pcFile);
end


in = load( spFile );
amp = in.data;

in = load( pcFile );
pc = in.pc;

end