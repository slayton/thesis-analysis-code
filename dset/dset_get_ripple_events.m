function [dset burstWin, peakTs] = dset_get_ripple_events(dset, varargin)
    
    bc = dset.channels.base;
    ic = dset.channels.ipsi;
    cc = dset.channels.cont;

    args.high_thold = 7;
    args.low_thold =  4;
    args.min_burst_len = .01;
    
    winIdx = round( [-.2 .2] *  dset.eeg(1).fs);
    window = [winIdx(1):winIdx(2)];
    
    if ~isfield(dset.eeg(1), 'rippleband')
        dset = dset_filter_eeg_ripple_band(dset);
    end
    
    nSamp = numel(dset.eeg(bc).data);
    dt = dset.eeg(bc).fs;
    st = dset.eeg(bc).starttime;
    ts = st + (0:(nSamp-1))*dt;


    ind = 1:numel(dset.eeg(bc).rippleband);
    h = abs( hilbert( dset.eeg(bc).rippleband ));


    high_seg = logical2seg(ind, h>=args.high_thold * std(h));
    low_seg = logical2seg(ind, h>=args.low_thold * std(h));

    [b n] = inseg(low_seg, high_seg);
    burstIdx = low_seg(logical(n),:);  
    burstIdx = round( mean( burstIdx, 2));
    
    %remove bursts that are too near to the beginning or the end of the
    %epoch for a complete window to be taken
    burstIdx = burstIdx( burstIdx > -1 * min(window));
    burstIdx = burstIdx( burstIdx < nSamp - max(window));


    burstWin = bsxfun(@plus, burstIdx, window);

    % get the data segments in the burst window
    ripples = dset.eeg(bc).rippleband(burstWin);

    % find the max value in the segment
    [m maxInd] = max(ripples, [], 2);

    % find the index of the peak, and calculate a new window
    peakIdx = burstIdx + maxInd - find( window == 0);
    ripWin = bsxfun(@plus, peakIdx, window);
    
    peakTs = interp1(1:nSamp, ts, peakIdx);
    
    dset.eeg(bc).rips = dset.eeg(bc).rippleband(ripWin);
    dset.eeg(ic).rips = dset.eeg(ic).rippleband(ripWin);
    dset.eeg(cc).rips = dset.eeg(cc).rippleband(ripWin);
   
end