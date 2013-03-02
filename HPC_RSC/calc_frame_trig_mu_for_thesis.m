clearvars -except MultiUnit LFP

win = [-.25 .5];


N = numel(MultiUnit);
% Fs = timestamp2fs(LFP{1}.ts);

% [hpcRate, ctxRate] = deal( nan(N, 151) );
hpcRate = {};

eventLenThold = [.250 inf ]; %<============

for i = 1 : N
    
    mu = MultiUnit{i};
%     eeg = LFP{i};
    
    % DETECT SWS, Ripples, and MU-Bursts
%     [sws, ripTs] = classify_sleep(eeg.ripple, eeg.rippleEnv, eeg.ts);
    muBursts = find_mua_bursts(mu);
    cFrames = find_ctx_frames(mu);
     
%     events = seg_and(muBursts, cFrames);
    events = muBursts;
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
    
    [~, ts, ~, hpcRate{i}] = meanTriggeredSignal( mu.ts( muPkIdx ), mu.ts, mu.hpc, win);
%     [ctxRate(i,:), ts]= meanTriggeredSignal( mu.ts( muPkIdx ), mu.ts, mu.ctx, win);
    
end
fprintf('DONE!\n');
%%
T = ts * 1000;
r = cell2mat(hpcRate');
m = mean(r);
e = std(r) * 1.96 / sqrt( size(r,1) );

figure;
ax = axes;
[p, l] = error_area_plot(T, m, e, 'Parent', ax);
set(p,'FaceColor', [1 .7 .7], 'edgecolor','none');
set(l,'Color', 'k');

set(ax,'Xlim', [-100 400]);

[~, idx] = findpeaks(m);
pkTs = T(idx);
pkTs = pkTs(pkTs > 0 & pkTs<eventLenThold(2)*1000);

for i = 1:numel(pkTs)
    line( pkTs(i) * [1 1], [0 max(m)], 'Color', 'k');
end
set( ax, 'XTick', unique([ get(gca,'Xtick'), pkTs]));
    

tmp = round(eventLenThold*1000);
drawnow;
plot2svg( sprintf('/data/HPC_RSC/hpc_frame_trig_mu_rate_%d_%d.svg', tmp(1), tmp(2)), gcf);

