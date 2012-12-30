function dset = dset_filter_eeg_sharpwave(dset, varargin)
    
    swFilt = getfilter(dset.eeg(1).fs, 'sharpwave', 'win');
    
    data = cell2mat({dset.eeg.data});
    
    data = filtfilt(swFilt,1,data);
    for i = 1:numel(dset.eeg)
        dset.eeg(i).sharpwaveBand = data(:,i);
    end

end