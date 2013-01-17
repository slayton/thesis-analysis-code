
clear;

eList = dset_list_epochs('Run');
nEpoch = size(eList, 1);


for i = 1:nEpoch
    
    fprintf('\n');
    d = dset_load_all(eList{i,:});
    results(i) = calc_bilateral_run_decoding_stats(d, 'PLOT', 0);
end