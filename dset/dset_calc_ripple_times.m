function [dset peakIdx] = dset_calc_ripple_times(dset, varargin)
    

    args.high_thold = 7;
    args.low_thold =  4;
    args.min_burst_len = .01;
    
    winIdx = round( [-.2 .2] *  dset.eeg(1).fs);
    window = [winIdx(1):winIdx(2)];
    
    
    % filter eeg if not yet filtered
    if ~isfield(dset.eeg(1), 'rippleband')
        dset = dset_filter_eeg_ripple_band(dset);
    end
    
    % construct timestamps
    nSamp = numel(dset.eeg(1).data);
    ts = dset_calc_timestamps( dset.eeg(1).starttime, numel( dset.eeg(1).data ), dset.eeg(1).fs );
    ind = 1:nSamp;
    
    % Get envelope of signal and find peaks, %use a high and low peak so
    
    ripHilbert = abs( hilbert( dset.eeg(1).rippleband ));
    high_seg = logical2seg( ind, ripHilbert>=args.high_thold * std(ripHilbert) );
    low_seg = logical2seg( ind, ripHilbert>=args.low_thold * std(ripHilbert) );
    
    [b n] = inseg(low_seg, high_seg);
    
    % get the lower segments with a high peak too
    ripWin = low_seg( logical(n), :);
   
    findMaxEnvFunc = @(x,y) max( ripHilbert(x:y) );
    
    % fid the peak of the envelope within the window
    [~, peakIdx] = arrayfun(findMaxEnvFunc, ripWin(:,1), ripWin(:,2) );
    
    % correct peakIdx offset
    peakIdx = peakIdx + ripWin(:,1);
    
%     burstIdx = low_seg( logical(n), : );  
%     burstIdx = round( mean( burstIdx, 2));
%     
%     %remove bursts that are too near to the beginning or the end of the
%     %epoch for a complete window to be taken
%     burstIdx = burstIdx( burstIdx > -1 * min(window));
%     burstIdx = burstIdx( burstIdx < nSamp - max(window));
% 
% 
%     burstWin = bsxfun(@plus, burstIdx, window);
% 
%     % get the data segments in the burst window
%     ripples = dset.eeg(1).rippleband(burstWin);
% 
%     % find the max value in the segment
%     [m maxInd] = max(ripples, [], 2);
% 
%     % find the index of the peak, and calculate a new window
%     peakIdx = burstIdx + maxInd - find( window == 0);
%     ripWin = bsxfun(@plus, peakIdx, window);
%     
%     peakTs = interp1(1:nSamp, ts, peakIdx);
    
    ripWin = bsxfun(@plus, peakIdx, window);
    
    dset.ripples = struct();
    dset.ripples.window = window;
    dset.ripples.peakIdx = peakIdx;
    dset.ripples.rips{1} = dset.eeg(1).rippleband(ripWin);
    dset.ripples.rips{3} = dset.eeg(3).rippleband(ripWin);
    dset.ripples.peakIdx = peakIdx;
    
    dset.ripples = orderfields(dset.ripples);    
    
end