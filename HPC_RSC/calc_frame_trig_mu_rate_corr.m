clearvars -except MultiUnit LFP

win = [-.25 .5];


N = numel(MultiUnit);
Fs = timestamp2fs(LFP{1}.ts);

[hpcRateHighCorr, ctxRateHighCorr] = deal( nan(N, 151) );
[hpcRateLowCorr, ctxRateLowCorr] = deal( nan(N, 151) );

eventLenThold = [.2 .4 ]; %<============
corrThold = .25;

c = {};
for i = 1 : N
    
    mu = MultiUnit{i};
    eeg = LFP{i};
    
    % DETECT SWS, Ripples, and MU-Bursts
    [sws, ripTs] = classify_sleep(eeg.ripple, eeg.rippleEnv, eeg.ts);
    muBursts = find_mua_bursts(mu);
    cFrames = find_ctx_frames(mu);
     
%     events = seg_and(muBursts, cFrames);
    events = muBursts;
    events = durationFilter(events, eventLenThold);
  
    nEvent = size(events,1);
    

    %
    if nEvent < 2
        continue;
    end
    
    % Classify burst by SWS state
    %     swsIdx = inseg(sws, muBursts, 'partial');
    muPkIdxHC = [];
    muPkIdxLC = [];
    
    trigHighCorr = [];
    trigLowCorr = [];
    
    c{i} = zeros(nEvent,1);
    for iEvent = 1:nEvent
        
        b = events(iEvent,:);
        
        startIdx = find( b(1) == mu.ts, 1, 'first');
        
        tmpIdx = mu.ts>=b(1) & mu.ts <= b(2);
        r = mu.hpc( tmpIdx );
        
        [~, pk] = findpeaks(r); % <------- FIRST LOCAL MAX
        
        if numel(pk)<1
            continue
        end
        pk = pk + startIdx -1;
        
        
        c{i}(iEvent) = corr( diff(mu.hpc(tmpIdx)'), diff(mu.ctx(tmpIdx)') );
        
        if c{i}(iEvent) <= -1 * corrThold
            
            trigLowCorr = [trigLowCorr, pk(1)];
        
        elseif c{i}(iEvent) >= corrThold
            
            trigHighCorr = [trigHighCorr, pk(1)];
        end
                    
    end
     
    
    fprintf('%d - H:%d L:%d\n', i, numel(trigHighCorr), numel(trigLowCorr) );
    
    [hpcRateHighCorr(i,:), ts] = meanTriggeredSignal( mu.ts( trigHighCorr ), mu.ts, mu.hpc, win);
    [ctxRateHighCorr(i,:), ts]= meanTriggeredSignal( mu.ts( trigHighCorr ), mu.ts, mu.ctx, win);
    
    [hpcRateLowCorr(i,:), ts] = meanTriggeredSignal( mu.ts( trigLowCorr ), mu.ts, mu.hpc, win);
    [ctxRateLowCorr(i,:), ts]= meanTriggeredSignal( mu.ts( trigLowCorr ), mu.ts, mu.ctx, win);
    
end
fprintf('DONE!\n');
%%
f = figure('Position', [360 450 630 600]);
ax = [];

ax(1) = subplot(211);
line(ts, nanmean(hpcRateHighCorr), 'color', 'r', 'linewidth', 2);
line(ts, nanmean(hpcRateLowCorr), 'color', 'k', 'linewidth', 2);

legend('High Corr', 'Low Corr');
title('HPC Frame Triggered HPC MU Rate ');

ax(2) = subplot(212);
line(ts, nanmean(ctxRateHighCorr), 'color', 'r', 'linewidth', 2);
line(ts, nanmean(ctxRateLowCorr), 'color', 'k', 'linewidth', 2);

legend('High Corr', 'Low Corr');
title('HPC Frame Triggered CTX MU Rate ');


set(ax,'XLim', [-.25 .5]);

% plot2svg('/data/HPC_RSC/frame_start_triggered_mu_rate_by_corr.svg',gcf);

