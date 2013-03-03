function [meanSpec, stdSpec,  freqs, spec] = meanTriggeredSpectrum(triggerTimes, ts, wave, win)
[~, ts, ~, wave] = meanTriggeredSignal(triggerTimes, ts, wave, win);

Fs = 1 / (ts(2) - ts(1));

nTrigger = numel(triggerTimes);

nTapers = 2;

freqs = 1:350;

spec = nan(nTrigger, numel(freqs));


parfor idx = 1:nTrigger
    hs = spectrum.mtm(nTapers);
    s = psd(hs, wave(idx,:), 'Fs', Fs, 'FreqPoints', 'User Defined', 'FrequencyVector', freqs, 'SpectrumType', 'twosided');
    spec(idx,:) = s.Data;
end
     
meanSpec = mean(spec);
stdSpec = std(spec);




