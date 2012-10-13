function data = dset_compute_ripple_params(dset)
    dset = dset_calc_ripple_times(dset);    
    dset = dset_calc_ripple_spectrum(dset);
    
    data.rips = dset.ripples.rips;
    data.spect = dset.ripples.spect;
    data.spectW = dset.ripples.spectW;
    data.f = dset.ripples.f;
    data.peakTs = dset.ripples.peakTs;
    data.peakFr = dset.ripples.peakFreq;
    data.window = w;
    data.fs = dset.eeg(1).fs;
    data.raw{1} = dset.eeg(1).data(w);
    data.raw{3} = dset.eeg(3).data(w);
    data.description = dset_get_description_string(dset);
    
    data.peakFrM = {zeros(size(data.rips{1}, 1),1), [], zeros(size(data.rips{1}, 1),1)};
    winIdx = 201:401;

    for waveInd = 1:size(data.rips{1},1)
        
        [~, indB] = findpeaks( data.rips{1}(waveInd,:) );
        [~, indC] = findpeaks( data.rips{3}(waveInd,:) );
                
        data.peakFrM{1}(waveInd) = dset.eeg(1).fs / mean( diff(indB) );
        data.peakFrM{3}(waveInd) = dset.eeg(1).fs / mean( diff(indC) );
        
    end
    
    
    data = orderfields(data);
 
    

end