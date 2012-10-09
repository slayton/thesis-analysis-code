function dset = dset_filter_eeg_ripple_band(dset, varargin)
    
    rFilt = getfilter(dset.eeg(1).fs, 'ripple', 'win');
    
    data = cell2mat({dset.eeg.data});
    
    filtfilt(rFilt,1,data);
    for i = 1:numel(dset.eeg)
        dset.eeg(i).rippleband = data(:,i);
    end

end