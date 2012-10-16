function [peakFrM] = dset_calc_ripple_mean_freq(dset)

    data = dset.ripples;
    
    nRipple = size(data.rip{1},1);
    peakFrM = {zeros(nRipple,1), [], zeros(nRipple,1)};

    for indRipple = 1:nRipple
        
%         [~, indB] = findpeaks( data.rip{1}(indRipple,:) );
%         [~, indC] = findpeaks( data.rip{3}(indRipple,:) );
                
        [~, indB] = findpeaks( abs(hilbert( data.rip{1}(indRipple,:) )));
        [~, indC] = findpeaks( abs(hilbert( data.rip{3}(indRipple,:) )));
    
        peakFrM{1}(indRipple) = dset.eeg(1).fs / mean( diff(indB) );
        peakFrM{3}(indRipple) = dset.eeg(1).fs / mean( diff(indC) );
        
    end
    

end