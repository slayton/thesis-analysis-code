
epochsToAnalyze = {'sleep', 'run'};

add_ref = 0;

for eNumber = 1:numel(epochsToAnalyze)
    
    epoch = epochsToAnalyze{eNumber};
    epochList = dset_list_epochs(epoch);
    
    parfor i = 1:size(epochList,1);
        d = dset_load_all(epochList{i,1},epochList{i,2}, epochList{i,3});
        
        if add_ref == 1
            fprintf('\tRemoving reference from EEG\n');
            d = dset_add_ref_to_eeg(d, 1);
        end
        
        fprintf('\tComputing ripple parameters\n');
        rp = dset_calc_ripple_params(d);
        rp.description = dset_get_description_string(d);
        epData(i) = rp;
    end
    data.(epoch) = epData;
end

if add_ref == 0
    saveFile = '/data/franklab/bilateral/all_ripples.mat';
elseif add_ref == 1
    saveFile = '/data/franklab/bilateral/all_ripples_ref.mat';
end
fprintf('Saving file: %s\n', saveFile);
save(saveFile, 'data');
