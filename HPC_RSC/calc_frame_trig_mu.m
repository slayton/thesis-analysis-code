clearvars -except MultiUnit LFP

win = [-.25 .5];


N = numel(MultiUnit);
Fs = timestamp2fs(LFP{1}.ts);

[hpcRate, ctxRate] = deal( nan(N, 151) );

eventLenThold = [.2 .4 ]; %<============

for i = 1 : N
    
    mu = MultiUnit{i};
    eeg = LFP{i};
    
    % DETECT SWS, Ripples, and MU-Bursts
    [sws, ripTs] = classify_sleep(eeg.ripple, eeg.rippleEnv, eeg.ts);
    muBursts = find_mua_bursts(mu);
    cFrames = find_ctx_frames(mu);
    
    % Filter MU-Bursts
%     muBursts = durationFilter(muBursts, eventLenThold);
%     cFrames = durationFilter(cFrames, eventLenThold);
%     events = muBursts( inseg(cFrames, muBursts, 'partial') , : );
    
    events = seg_and(muBursts, cFrames);
    events = durationFilter(events, eventLenThold);
  
    nEvent = size(events,1);
    
    fprintf('%d - detected %d events\n', i, nEvent);
    %
    if nEvent < 2
        continue;
    end
    
    % Classify burst by SWS state
    %     swsIdx = inseg(sws, muBursts, 'partial');
    muPkIdx = [];
    
    for iEvent = 1:nEvent
        
        b = events(iEvent,:);
        
        startIdx = find( b(1) == mu.ts, 1, 'first');
        
        r = mu.hpc( mu.ts>=b(1) & mu.ts <= b(2) );
        
        [~, pk] = findpeaks(r); % <------- FIRST LOCAL MAX
        
        if numel(pk)<1
            continue
        end
        pk = pk + startIdx -1;
        muPkIdx = [muPkIdx, pk(1)];  %#ok
        
    end
    
    [hpcRate(i,:), ts] = meanTriggeredSignal( mu.ts( muPkIdx ), mu.ts, mu.hpc, win);
    [ctxRate(i,:), ts]= meanTriggeredSignal( mu.ts( muPkIdx ), mu.ts, mu.ctx, win);
    
end
fprintf('DONE!\n');
%%
[l, f, ax] = plotAverages(ts, nanmean(hpcRate), ts, nanmean(ctxRate));

legend(l, {'HPC MU Rate', 'RSC MU Rate'});
set(f,'Position', [300 500 800 300]);
set(ax,'Position', [.1 .15 .8 .75]);

if numel(eventLenThold)==2
    title( ax, sprintf('Event Dur: %d to %d ms', eventLenThold * 1000), 'fontSize', 16);
else
    title( ax, sprintf('Event Dur: %d to Inf', eventLenThold * 1000), 'fontSize', 16);
end

plot2svg('/data/HPC_RSC/frame_start_triggered)mu_rate.svg',gcf);

