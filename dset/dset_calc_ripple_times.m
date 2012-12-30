function [dset, peakIdx, winIdx] = dset_calc_ripple_times(dset, varargin)
    
    args.high_thold = 7;
    args.low_thold =  4;
    args.min_burst_len = .01;
    
    
    % FILTER EEG - if not yet filtered
    if ~isfield(dset.eeg(1), 'rippleband')
        dset = dset_filter_eeg_ripple_band(dset);
    end
    
    % construct indexing vector
    nSamp = numel(dset.eeg(1).data);
    ind = 1:nSamp;
    
    % only define and detect ripples using CHAN #1
    ripLfp = dset.eeg(1).rippleband;
    
    % Get envelope of signal and find bursts
    ripHilbert = abs( hilbert( ripLfp ));
    
    high_seg = logical2seg( ind, ripHilbert >= args.high_thold * std(ripHilbert) );
    low_seg = logical2seg( ind, ripHilbert >= args.low_thold * std(ripHilbert) );
    
    % which low segments contain high segments
    [~, n] = inseg(low_seg, high_seg);
    
    % define these low segments as the bursts
    winIdx = low_seg( logical(n), :);
   
    % find the index of the peak of the rippleband lfp within the window
    findMaxEnvFunc = @(x,y) max( ripLfp(x:y) );
    
    % select the sample in the burst with the largest envelope as the peak
    [~, peakIdx] = arrayfun(findMaxEnvFunc, winIdx(:,1), winIdx(:,2) );
    
    % correct peakIdx offset
    peakIdx = peakIdx + winIdx(:,1) - 1;
    
    % remove peaks that are within 500 samples of the beginning or the end
    % of the recording
    validPeaks = peakIdx > 500 & peakIdx < (nSamp - 500);
    
    % remove invalid peaks
    peakIdx = peakIdx(validPeaks);
    winIdx = winIdx(validPeaks,:);
        
    dset.ripples.peakIdx = peakIdx;
    dset.ripples.eventOnOffIdx = winIdx;    
    
end