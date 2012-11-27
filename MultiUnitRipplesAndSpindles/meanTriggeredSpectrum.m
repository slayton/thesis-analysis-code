function [meanSpec, stdSpec,  freqs, spec] = meanTriggeredSpectrum(triggerTimes, ts, wave, win)
[~, ~, ts, wave] = meanTriggeredSignal(triggerTimes, ts, wave, win);

Fs = 1 / (ts(2) - ts(1));

nTrigger = numel(triggerTimes);

nTapers = 4;
hs = spectrum.mtm(nTapers);

s = psd(hs, wave(1,:), 'Fs', Fs);

freqs = s.Frequencies;

spec = nan(nTrigger, numel(freqs));

open_pool;

for idx = 1:nTrigger
    s = psd(hs, wave(idx,:), 'Fs', Fs);
    spec(idx,:) = s.Data;
end
    
meanSpec = mean(spec);
stdSpec = std(spec);




