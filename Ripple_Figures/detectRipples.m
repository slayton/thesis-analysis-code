function [peakIdx, winIdx] = detectRipples(ripBand, ripHilbert, Fs, varargin)
    
    args.high_thold = 7;
    args.low_thold =  4;
    args.min_burst_len = .01;
   
    args = parseArgs(varargin, args);

    nSamp = numel(ripBand);
    ind = 1:nSamp;
    
%     if args.filtered == 0
%         rFilt = getfilter(Fs, 'ripple', 'win');
%         ripBand = filtfilt(rFilt, 1, eeg);
%        
%         ripHilbert = nan .* ripBand;
%         validSeg = logical2seg( isfinite( ripBand ) );
%         for iSeg = 1:size(validSeg, 1)
% 
%             idx = validSeg(iSeg,1):validSeg(iSeg,2);
%             ripHilbert(idx) = abs( hilbert( ripBand(idx) ) );
% 
%         end
%     else
%         ripHilbert = eeg;
%     end

    % Get envelope of signal and find bursts

    high_seg = logical2seg( ind, ripHilbert >= args.high_thold * nanstd(ripHilbert) );
    low_seg = logical2seg( ind, ripHilbert >= args.low_thold * nanstd(ripHilbert) );

    % which low segments contain high segments
    [~, n] = inseg(low_seg, high_seg);

    % define these low segments as the bursts
    winIdx = low_seg( logical(n), :);

    % find the index of the peak of the rippleband lfp within the window
    findMaxEnvFunc = @(x,y) max( ripBand(x:y) );

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
    
end