clearvars -except MultiUnit LFP

win = [-.25 .5];


N = numel(MultiUnit);
Fs = timestamp2fs(LFP{1}.ts);

[hpcRateHighCorr, ctxRateHighCorr] = deal( nan(N, 151) );
[hpcRateLowCorr, ctxRateLowCorr] = deal( nan(N, 151) );

eventLenThold = [.15 inf ]; %<============
corrThold = .35;

c = {};
hSamp = {};
lSamp = {};
aSamp = {};
xc = nan(201, N);
tShift = nan(N,1);
for i = 1 : N
    
    mu = MultiUnit{i};
    eeg = LFP{i};
    
    [xc(:,i), lgs] = xcorr(mu.hpc, mu.ctx, 100);
    [~, xcMaxIdx] = max( xc(:,i) );
    tShift(i) = lgs(xcMaxIdx)+1;
    
    
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
%     trigAll = [];
    
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
        
%         c{i}(iEvent) = corr( mu.hpc( circshift(tmpIdx, [0, -tShift(i)]))', mu.ctx(tmpIdx)' );
        c{i}(iEvent) = corr( diff( mu.hpc(tmpIdx)'), diff( mu.ctx(tmpIdx)') ); 
%         c{i}(iEvent) = corr( mu.hpc( tmpIdx)', mu.ctx(tmpIdx)' );
        
%         trigAll = [trigAll, pk(1)];
        if c{i}(iEvent) <= -1 * corrThold
            
            trigLowCorr = [trigLowCorr, pk(1)];
        
        elseif c{i}(iEvent) >= corrThold
            
            trigHighCorr = [trigHighCorr, pk(1)];
        end
                    
    end
     
    
    fprintf('%d - H:%d L:%d\n', i, numel(trigHighCorr), numel(trigLowCorr) );
    
    [~, ts, ~, hSamp{i}] = meanTriggeredSignal( mu.ts( trigHighCorr ), mu.ts, mu.hpc, win);
    [~,  ~, ~, lSamp{i}] = meanTriggeredSignal( mu.ts( trigLowCorr ), mu.ts, mu.hpc, win);
%     [~,  ~, ~, aSamp{i}] = meanTriggeredSignal( mu.ts( trigAll), mu.ts, mu.hpc, win);
    
end
fprintf('DONE!\n');

%%
H = cell2mat(hSamp');
L = cell2mat(lSamp');
% A = cell2mat(aSamp');

mH = mean(H);
mL = mean(L);
% mA = mean(A);

sH = std(H);
sL = std(L);
% sA = std(A);

nH = size(H,1);
nL = size(L,1);
% nA = size(A,1);

f = figure('Position', [360 450 630 400]);
ax = [];

ax(1) = axes('FontSize', 14);%subplot(211);

[p(1), l(1)] = error_area_plot(ts, mH, sH * 1.96 / sqrt(nH), 'Parent', ax(1));
[p(2), l(2)] = error_area_plot(ts, mL, sL * 1.96 / sqrt(nL), 'Parent', ax(1));
% [p(3), l(3)] = error_area_plot(ts, mA, sA * 1.96 / sqrt(nA), 'Parent', ax(1));


set(p(1),'FaceColor', [.9 .3 .3]);
set(p(2),'FaceColor', [.3 .9 .3]);
set(p,'EdgeColor', 'none');

set(l(1), 'Color', [.3 0 0]);
set(l(2), 'Color', [0 .3 0]);
% set(p(3),'FaceColor', [.3 .3 .9]);




legend(p, {'High Corr', 'Low Corr'});
title('HPC Frame Triggered HPC MU Rate ');


% ax(2) = subplot(212);
% line(ts, nanmean(ctxRateHighCorr), 'color', 'r', 'linewidth', 2);
% line(ts, nanmean(ctxRateLowCorr), 'color', 'k', 'linewidth', 2);
% 
% legend('High Corr', 'Low Corr');
% title('HPC Frame Triggered CTX MU Rate ');


set(ax,'XLim', [-.25 .5]);
% plot2svg('/data/HPC_RSC/hpc_frame_trig_mu_rate_w_corr.svg',gcf);

