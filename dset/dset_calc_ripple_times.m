function [dset, peakIdx] = dset_calc_ripple_times(dset, varargin)
    
    args.high_thold = 7;
    args.low_thold =  4;
    args.min_burst_len = .01;
    
    
    % FILTER EEG - if not yet filtered
    if ~isfield(dset.eeg(1), 'rippleband')
        dset = dset_filter_eeg_ripple_band(dset);
    end
    
    % construct timestamps
    nSamp = numel(dset.eeg(1).data);
    ind = 1:nSamp;
    
    % only define and detect ripples using CHAN #1
    ripLfp = dset.eeg(1).rippleband;
    
    % Get envelope of signal and find bursts
    ripHilbert = abs( hilbert( ripLfp ));
    high_seg = logical2seg( ind, ripHilbert>=args.high_thold * std(ripHilbert) );
    low_seg = logical2seg( ind, ripHilbert>=args.low_thold * std(ripHilbert) );
    
    % which low segments contain high segments
    [~, n] = inseg(low_seg, high_seg);
    
    % define these low segments as the bursts
    ripWin = low_seg( logical(n), :);
   
    % find the index of the peak of the rippleband lfp within the window
    findMaxEnvFunc = @(x,y) max( ripLfp(x:y) );
    
    % select the sample in the burst with the largest envelope as the peak
    [~, peakIdx] = arrayfun(findMaxEnvFunc, ripWin(:,1), ripWin(:,2) );
    
    % correct peakIdx offset
    peakIdx = peakIdx + ripWin(:,1);
    
    % remove peaks that are within 500 samples of the beginning or the end
    % of the experiment
    validPeaks = peakIdx > 500 & peakIdx < (nSamp - 500);
    
    peakIdx = peakIdx(validPeaks);
    dset.ripples.peakIdx = peakIdx;
    
    
end