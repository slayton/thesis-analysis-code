function dset = dset_filter_eeg_theta_band(dset, varargin)
    
    tFilt = getfilter(dset.eeg(1).fs, 'theta', 'win');
    
    data = cell2mat({dset.eeg.data});
    
    data = filtfilt(tFilt,1,data);
    for i = 1:numel(dset.eeg)
        dset.eeg(i).thetaband = data(:,i);
    end

end