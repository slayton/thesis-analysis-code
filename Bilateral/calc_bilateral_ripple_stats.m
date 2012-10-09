function [freq, dur, amp, rippleWindows] = calc_bilateral_ripple_stats(eeg, baseChan, ipsiChan, contChan)
minDt = .025;

%%
for i = 1:numel(eeg)
    if  isfield(eeg(i), 'timestamps')
        eeg(i).starttime = eeg(i).timestamps(1);
    elseif ~isfield(eeg(i), 'starttime')
        disp('No starttime member for eeg');
        continue;
    end
    
    if i == baseChan || i==ipsiChan || i==contChan
        disp('Calculating ripple bursts');
        [rippleWindows{i}, maxTimes{i}, maxPower{i}, ~, ripplePower{i}] = find_rip_burst(eeg(i).data, eeg(i).fs, eeg(i).starttime);
    end
end

%%
%% -- Ripple Frequency Analysis
%%
%% get the indecies of events that occur on both sets of channels
baseIdx = logical(zeros(size(maxTimes{baseChan})));
ipsiIdx = logical(zeros(size(maxTimes{baseChan})));
contIdx = logical(zeros(size(maxTimes{baseChan})));

nearestIpsi = interp1(maxTimes{ipsiChan}, maxTimes{ipsiChan}, maxTimes{baseChan}, 'nearest');
ipsiIdx = abs(nearestIpsi - maxTimes{baseChan}) <= minDt;

nearestCont = interp1(maxTimes{contChan}, maxTimes{contChan}, maxTimes{baseChan}, 'nearest');
contIdx = abs(nearestCont - maxTimes{baseChan}) <= minDt;


%% - Calculate the dominant frequency for the selected events
[bvbRipFreq bvbSpec bvbFreq] = dset_calc_event_peak_freq(eeg(baseChan).data, eeg(baseChan).starttime, eeg(baseChan).fs, maxTimes{baseChan});
[bviRipFreq bviSpec bviFreq] = dset_calc_event_peak_freq(eeg(ipsiChan).data, eeg(ipsiChan).starttime, eeg(ipsiChan).fs, maxTimes{baseChan}(ipsiIdx));
[bvcRipFreq bvcSpec bvcFreq] = dset_calc_event_peak_freq(eeg(contChan).data, eeg(contChan).starttime, eeg(contChan).fs, maxTimes{baseChan}(contIdx));

bviRho = corr(bvbRipFreq(ipsiIdx)', bviRipFreq', 'type', 'spearman');
bvcRho = corr(bvbRipFreq(contIdx)', bvcRipFreq', 'type', 'spearman');

freq.baseVsIpsi.base = bvbRipFreq(ipsiIdx)';
freq.baseVsIpsi.ipsi = bviRipFreq';

freq.baseVsCont.base = bvbRipFreq(contIdx)';
freq.baseVsCont.cont = bvcRipFreq';

freq.baseVsIpsiCorr = bviRho;
freq.baseVsContCorr = bvcRho;

%% Plot the dominant frequency relationships
% figure('Position', [300 300 300 700]);
% subplot(211);
% 
% plot(bvbRipFreq(ipsiIdx), bviRipFreq, '.');
% title(['Correlation: ', num2str(round(bviRho*100)/100)]);
% 
% subplot(212);
% plot(bvbRipFreq(contIdx), bvcRipFreq, '.');
% title(['Correlation: ', num2str(round(bvcRho*100)/100)]);

%%
%% -- Ripple Duration Analysis
%%
%% get event durations
baseDuration = diff(rippleWindows{baseChan}');
ipsiDuration = diff(rippleWindows{ipsiChan}');
contDuration = diff(rippleWindows{contChan}');
%% get indices of overlapping time windows

[baseIdxIpsi ipsiIdxIpsi] = calc_time_window_overlap(rippleWindows{baseChan}, rippleWindows{ipsiChan});
[baseIdxCont contIdxCont] = calc_time_window_overlap(rippleWindows{baseChan}, rippleWindows{contChan});

%% Plot the overlaps to make sure they are real
% figure;
% axes;
% for i = 1:numel(baseIdxIpsi)
%    line(rippleWindows{baseChan}(baseIdxIpsi(i),:), repmat([0+.1*i],1,2));
%    line(rippleWindows{ipsiChan}(ipsiIdxIpsi(i),:), repmat([0+.1*i]+.05,1,2), 'color', 'red');
% end
%%

bviRhoDur = corr(baseDuration(baseIdxIpsi)', ipsiDuration(ipsiIdxIpsi)', 'type', 'spearman');
bvcRhoDur = corr(baseDuration(baseIdxCont)', contDuration(contIdxCont)', 'type', 'spearman');

dur.baseVsIpsi.base = baseDuration(baseIdxIpsi);
dur.baseVsIpsi.ipsi = ipsiDuration(ipsiIdxIpsi);

dur.baseVsCont.base = baseDuration(baseIdxCont);
dur.baseVsCont.cont = contDuration(contIdxCont);

dur.baseVsIpsiCorr = bviRhoDur;
dur.baseVsContCorr = bvcRhoDur;
% 
% figure('Position', [300 300 300 700]);
% subplot(211);
% 
% 
% plot(baseDuration(baseIdxIpsi), ipsiDuration(ipsiIdxIpsi),'.');
% title(['Correlation: ', num2str(round(bviRhoDur*100)/100)]);
% subplot(212);
% 
% plot(baseDuration(baseIdxCont), contDuration(contIdxCont),'.');
% title(['Correlation: ', num2str(round(bvcRhoDur*100)/100)]);
% 
% set(get(gcf, 'Children'), 'Xlim', [0 .14], 'YLim', [0 .14]);

%%
%% -- Ripple Power Analysis
%%

bviRhoPow = corr(maxPower{baseChan}(baseIdxIpsi)', maxPower{ipsiChan}(ipsiIdxIpsi)', 'type', 'spearman');
bvcRhoPow = corr(maxPower{baseChan}(baseIdxCont)', maxPower{contChan}(contIdxCont)', 'type', 'spearman');

amp.baseVsIpsi.base = ripplePower{baseChan}(baseIdxIpsi)';
amp.baseVsIpsi.ipsi = ripplePower{ipsiChan}(ipsiIdxIpsi)';

amp.baseVsCont.base = ripplePower{baseChan}(baseIdxCont)';
amp.baseVsCont.cont = ripplePower{contChan}(contIdxCont)';

amp.baseVsIpsiCorr = bviRhoPow;
amp.baseVsContCorr = bvcRhoPow;
% 
% figure('Position', [300 300 300 700]);
% 
% subplot(211);
% 
% plot(ripplePower{baseChan}(baseIdxIpsi), ripplePower{ipsiChan}(ipsiIdxIpsi),'.');
% title(['Correlation: ', num2str(round(bviRhoPow*100)/100)]);
% % subplot(212);
% 
% plot(ripplePower{baseChan}(baseIdxCont), ripplePower{contChan}(contIdxCont),'.');
% title(['Correlation: ', num2str(round(bvcRhoPow*100)/100)]);
% set(get(gcf,'Children'), 'Xlim', [0 5e5], 'YLim', [0 5e5]);

