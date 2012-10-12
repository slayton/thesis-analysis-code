function dset = dset_calc_ripple_spectrum(dset)
    [dset w t] = dset_get_ripple_events(dset);    
        
    for j = 1:2:numel(dset.eeg);
        dset.ripples.raw{j} = dset.eeg(j).data(w);
    end
    
    
    winIdx = 201:401;

    fs = dset.eeg(1).fs;
    [~, ~, f, ~] = calc_ripple_spectrum(dset.ripples.raw{1}(1,winIdx), dset.eeg(1).fs);
    nFreq = numel(f);
    
    for ii = 1:2:numel(dset.ripples.rips)
        
        r = dset.ripples.raw{ii};
        nRip = size(r,1);
           
        [pkFr pkFrM] = deal( zeros(nRip, 1) );
        [sp, wsp]  = deal( zeros(nRip, nFreq) );

        parfor jj = 1:size(r,1)
            [sp(jj,:), wsp(jj,:), ~, pkFr(jj)]  = calc_ripple_spectrum(r(jj,winIdx), fs);
            [~, peakIdx] = findpeaks( r(jj,winIdx) );
            pkFrM(jj) = mean( 1 ./  (diff(peakIdx) / fs) );
        end
        
        dset.ripples.spect{ii} = sp;
        dset.ripples.spectW{ii} = wsp;
        dset.ripples.peakFreq{ii} = pkFr;
        dset.ripples.peakFreqM{ii} = pkFrM;
    end
    
    dset.ripples.f = f;

end

