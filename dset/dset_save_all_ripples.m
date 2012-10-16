
epochsToAnalyze = {'sleep', 'run'};

for eNumber = 1:numel(epochsToAnalyze)
    
    epoch = epochsToAnalyze{eNumber};
    epochList = dset_list_epochs(epoch);
    

    for i = 1:size(epochList,1);
        d = dset_load_all(epochList{i,1},epochList{i,2}, epochList{i,3});
        rp = dset_calc_ripple_params(d);
        rp.description = dset_get_description_string(d);
        data.(epoch)(i) = rp;
    end
    
end

saveFile = '/data/franklab/bilateral/all_ripples_tmp.mat';
fprintf('Saving file: %s\n', saveFile);
save(saveFile, 'data');
