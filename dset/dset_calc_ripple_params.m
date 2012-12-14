function [data, dset] = dset_calc_ripple_params(dset)
    fprintf('Calculating ripple times\n');
    dset = dset_calc_ripple_times(dset);    
    fprintf('Calculating ripple spectra\n');
    dset = dset_calc_ripple_spectrum(dset);
    
    data = dset.ripples;
%     data.rips = dset.ripples.rip;
%     data.spect = dset.ripples.spect;
%     data.spectW = dset.ripples.spectW;
%     data.f = dset.ripples.f;
%     data.peakTs = dset.ripples.peakTs;
%     data.peakFr = dset.ripples.peakFreq;
%     data.window = w;
    w = bsxfun(@plus, data.peakIdx, data.window);
    data.fs = dset.eeg(1).fs;
    data.raw{1} = dset.eeg(1).data(w);
    data.raw{2} = dset.eeg(2).data(w);
    data.raw{3} = dset.eeg(3).data(w);
    
    data.description = dset_get_description_string(dset);
    fprintf('Calculating ripple mean frequency\n');
    data.peakFrM = dset_calc_ripple_mean_freq(dset);
    
    data = orderfields(data);
 
    

end