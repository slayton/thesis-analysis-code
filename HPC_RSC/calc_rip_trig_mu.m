function f = calc_rip_trig_mu(MU, HPC, fld, p)

win = [-.25 .75];
N = numel(MU);
Fs = timestamp2fs(HPC(1).ts);

ripSamp = {  };
nRip = 1;
for i = 1 : N
    
    fprintf('%d ', i);
%     mu = MultiUnit{i};
    if isempty(p)
        [ripIdx, ripWin] = detectRipples(HPC(i).ripple, HPC(i).rippleEnv, Fs, 'pos_struct', [], 'ts', HPC(i).ts);
    else
        [ripIdx, ripWin] = detectRipples(HPC(i).ripple, HPC(i).rippleEnv, Fs, 'pos_struct', p(i), 'ts', HPC(i).ts);
    end
    ripTs = HPC(i).ts(ripIdx);
    %     ripTs = eeg.ts(ripWin(:,1));
    
    doubletIdx = filter_event_sets(ripTs, 2, [.5 .25 .5]);
    [tripletIdx, singletIdx] = filter_event_sets(ripTs, 3, [.5 .25 .5]);
    
    fprintf(' %d\t->\t%d\t%d\t%d\n', numel(ripTs), numel(singletIdx), numel(doubletIdx), numel(tripletIdx));
    
    [~, ts, ~, ripSamp{1,i}] = meanTriggeredSignal(ripTs, MU(i).ts, MU(i).(fld), win);
    ripSamp{2,i} = ripSamp{1,i}(singletIdx,:);
    ripSamp{3,i} = ripSamp{1,i}(doubletIdx,:);
    ripSamp{4,i} = ripSamp{1,i}(tripletIdx,:);
    
    %     [ctxTrip(i,:), ts] = meanTriggeredSignal(setTs, mu.ts, mu.ctx, win);
    %     [ctxSolo(i,:), ts] = meanTriggeredSignal(soloTs, mu.ts, mu.ctx, win);
    
    
end
fprintf('\n');

%%
f = figure;
ax = axes('NextPlot', 'add');
T = ts * 1000;
c = [0 0 0; .5 0 0; 0 .5 0; 0 0 .5];
[p, l] = deal([]);
for i = [1 2 3 4]
    r = cell2mat({ ripSamp{i,:}}');
    
    m = mean(r);
    e = std(r) * 1.96 / sqrt( size(r,1) );
    
    [p(i), l(i)] = error_area_plot(T, m, e, 'Parent', ax);
    set(p(i),'EdgeColor', 'none', 'FaceColor', c(i,:) + .4);
    set(l(i), 'color', c(i,:));
    
    [~, mIdx] = findpeaks(m);
    
    mTs = T(mIdx);
    mTs = mTs(mTs > 0 & mTs < 100);
    for j = 1:numel(mTs)
        line( mTs(j) * [1 1], [min(m), max(m)], 'color', 'k');
    end
    
    
    set(gca,'XTick', unique([get(gca,'XTick'), mTs]) );
    
end

set(ax,'Xlim', [-200 300]);
% legend(p, {'All', 'Singlets', 'Doublets', 'Triplets'});

% plot2svg( sprintf('/data/HPC_RSC/ripple_triggered_%s_mu.svg', upper(fld)) ,gcf);

end
% 
% %%
% ax = [];
% figure('Position', [100 260 560 420]);
% ax(1) = axes('FontSize', 14);
% 
% [p(1), l(1)] = error_area_plot(T, mSet, sSet * 1.96 / sqrt(nSet), 'Parent', ax);
% [p(2), l(2)] = error_area_plot(T, mSolo, sSolo * 1.96 / sqrt(nSolo), 'Parent', ax);
% 
% 
% set(p(1), 'FaceColor', [1 .8 .8], 'edgecolor', 'none');
% set(p(2), 'FaceColor', [.8 .8 1], 'edgecolor', 'none');
% 
% set(l(1),'Color', [.6 .2 .2]);
% set(l(2),'Color', [.2 .2 .6]);
% 
% % line(t[s, mean(hpcTrip), 'color', 'r', 'Parent', ax(1));
% % line(ts, mean(hpcSolo), 'color', 'k', 'Parent', ax(1));
% title(ax(1), 'Ripple Triggered HPC MU Rate');
% legend(ax(1), 'Doublets', 'Singlets');
% 
% 
% [~, mIdx] = findpeaks(mSet);
% mTs = T(mIdx);
% mTs = mTs(mTs > 0 & mTs < 300);
% for i = 1:numel(mTs)
%     line( mTs( [i, i]), [, max(mSet)], 'color', 'k');
% end
% 
% set(gca,'XTick', sort([get(gca,'XTick'), mTs]) );
% 
% 
% set(ax,'XLim', [-100 400]);
% 
% plot2svg( sprintf('/data/HPC_RSC/ripple_triggered_mu_HPC_rate_nRip%d.svg',nRip) ,gcf);
% 
% %%
% 
% figure('Position', [100 260 560 420]);
% ax(1) = subplot(211);
% ax(2) = subplot(212);
% rSet(ax,'FontSize', 14);
% 
% 
% line(ts, mean(hpcSet), 'color', 'r', 'Parent', ax(1));
% line(ts, mean(hpcSolo), 'color', 'k', 'Parent', ax(1));
% title(ax(1), 'Ripple Triggered HPC MU Rate');
% legend(ax(1), 'Doublets', 'Singlets');
% 
% line(ts, mean(ctxTrip), 'color', 'r', 'Parent', ax(2));
% line(ts, mean(ctxSolo), 'color', 'k', 'Parent', ax(2));
% title(ax(2), 'Ripple Triggered CTX MU Rate');
% 
% 
% rSet(ax,'XLim', [-.1 .4]);
% plot2svg( sprintf('/data/HPC_RSC/ripple_triggered_mu_HPC_RSC_rate_nRip%d.svg',nRip) ,gcf);
% 
% % figure('Position', [150 210 560 420]);
% % ax(1) = subplot(211);
% % ax(2) = subplot(212);
% % set(ax,'FontSize', 14);
% %
% % line(ts, mean(hpcTrip) ./ max( mean(hpcTrip)), 'color', 'r', 'Parent', ax(1));
% % line(ts, mean(ctxTrip) ./ max( mean(ctxTrip)), 'color', 'k', 'Parent', ax(1));
% % title(ax(1),'Ripple-Set Triggered MU Rate');
% % legend(ax(1), 'HPC', 'CTX');
% %
% % line(ts, mean(hpcSolo) ./ max( mean(hpcSolo)) , 'color', 'r', 'Parent', ax(2));
% % line(ts, mean(ctxSolo) ./ max( mean(ctxSolo)) , 'color', 'k', 'Parent', ax(2));
% % title(ax(2),'Solo-Ripple Triggered MU Rate');
% %
% %
% % set(ax,'XLim', win);