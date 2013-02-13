clearvars -except MultiUnit LFP

win = [-.25 .75];

N = numel(MultiUnit);
Fs = timestamp2fs(LFP{1}.ts);

[hpcAll, hpcTrip, hpcSolo, ctxAll,  ctxTrip, ctxSolo] = deal( nan(N, 201) );

for i = 1 : N
    
    fprintf('%d ', i);
    mu = MultiUnit{i};
    eeg = LFP{i};
    
    [ripIdx, ripWin] = detectRipples(eeg.ripple, eeg.rippleEnv, Fs);
    
    ripTs = eeg.ts(ripIdx);
      
    [setIdx, soloIdx] = filter_event_sets(ripTs, 3, [.5 .25 .5]);
    
    fprintf(' %d\t->\t%d\t:\t%d\n', numel(ripTs), numel(setIdx), numel(soloIdx));
    
    setTs = ripTs(setIdx);
    soloTs = ripTs(soloIdx);
    
    [hpcTrip(i,:), ts] = meanTriggeredSignal(setTs, mu.ts, mu.hpc, win);
    [hpcSolo(i,:), ts] = meanTriggeredSignal(soloTs, mu.ts, mu.hpc, win);
    
    [ctxTrip(i,:), ts] = meanTriggeredSignal(setTs, mu.ts, mu.ctx, win);
    [ctxSolo(i,:), ts] = meanTriggeredSignal(soloTs, mu.ts, mu.ctx, win);
    
end
fprintf('\n');

%%

figure('Position', [100 260 560 420]);
ax(1) = subplot(211);
ax(2) = subplot(212);
set(ax,'FontSize', 14);

line(ts, mean(hpcTrip), 'color', 'r', 'Parent', ax(1));
line(ts, mean(hpcSolo), 'color', 'k', 'Parent', ax(1));
title(ax(1), 'Ripple Triggered HPC MU Rate');
legend(ax(1), 'Sets', 'Solo');

line(ts, mean(ctxTrip), 'color', 'r', 'Parent', ax(2));
line(ts, mean(ctxSolo), 'color', 'k', 'Parent', ax(2));
title(ax(2), 'Ripple Triggered CTX MU Rate');


set(ax,'XLim', win);


figure('Position', [150 210 560 420]);
ax(1) = subplot(211);
ax(2) = subplot(212);
set(ax,'FontSize', 14);

line(ts, mean(hpcTrip) ./ max( mean(hpcTrip)), 'color', 'r', 'Parent', ax(1));
line(ts, mean(ctxTrip) ./ max( mean(ctxTrip)), 'color', 'k', 'Parent', ax(1));
title(ax(1),'Ripple-Set Triggered MU Rate');
legend(ax(1), 'HPC', 'CTX');

line(ts, mean(hpcSolo) ./ max( mean(hpcSolo)) , 'color', 'r', 'Parent', ax(2));
line(ts, mean(ctxSolo) ./ max( mean(ctxSolo)) , 'color', 'k', 'Parent', ax(2));
title(ax(2),'Solo-Ripple Triggered MU Rate');


set(ax,'XLim', win);