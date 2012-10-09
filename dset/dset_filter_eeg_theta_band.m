function dset = dset_filter_eeg(dset, varargin)
    
    rFilt = getfilter(dset.eeg(1).fs, 'theta', 'win');
    
    data = cell2mat({dset.eeg.data});
    
    filtfilt(rFilt,1,data);
    for i = 1:numel(dset.eeg)
        dset.eeg(1).rippleband = data(:,i);
    end

end