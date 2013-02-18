function convert_tt_files(baseDir)

if nargin==1
    plot = 0;
end

if ~exist(baseDir, 'dir')
    error('Dir %s does not exist', baseDir)
end


klustDir = fullfile(baseDir, 'kKlust');
if ~exist(klustDir, 'dir')
    mkdir(klustDir);
end


ep = 'amprun';

% exp_in = exp_load(baseDir, 'epochs', ep, 'data_types', {'pos'});
% in = setup_decoding_inputs(exp_in, ep);
[data, ttList] = load_dataset_waveforms(baseDir, ep);
% data = in.raw_amps;

data = select_amps_by_feature(data, 'feature', 'col', 'col_num', 8, 'range', [12 40]);
data = select_amps_by_feature(data, 'feature', 'amplitude', 'range', [125 inf]);
data = select_amps_by_feature(data, 'feature', 'col',   'col_num', 7, 'range', [.15 Inf]);

   
save(fullfile(klustDir, 'spikes.mat'), 'data');
save(fullfile(klustDir, 'ttMap.mat'), 'ttList');

return;




