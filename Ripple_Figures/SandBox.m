clear;
day = [18, 22, 23, 24];
ep = [3, 1, 1, 2];

C = [];
H = [];
fprintf('\n\n');

for E = 1:4
    
    epoch = sprintf('sleep%d', ep(E));
    edir = sprintf('/data/gh-rsc1/day%d', day(E));
    fName = sprintf('MU_HPC_RSC_%s.mat', upper(epoch));

    mu = load( fullfile(edir, fName) );
    mu = mu.mu;

    muBursts = find_mua_bursts(mu);
    bLen = diff(muBursts, [], 2);
    nBurst = size(muBursts,1);

    fprintf('Loaded %d bursts', nBurst); 

    thold = [.1 ];
    
    if numel(thold)==1
        idx = find( bLen > thold(1) );
    else
        idx = find( bLen > thold(1) & bLen < thold(2) );
    end
    
    nBurst = numel(idx);

    fprintf(', keeping %d\n', nBurst);

    hpcPkIdx = [];

    for i = 1:numel(idx)
       b = muBursts(idx(i),:);

       startIdx = find( b(1) == mu.ts, 1, 'first');

       r = mu.hpc( mu.ts>=b(1) & mu.ts <= b(2) );

       [~, pk] = findpeaks(r);
       pk = pk + startIdx -1;
%        pk = startIdx;
       hpcPkIdx = [hpcPkIdx, pk(1)];  %#ok
    end

    win = [-.5 .5];
    [mHpc, ~, ts] = meanTriggeredSignal(mu.ts(hpcPkIdx), mu.ts, mu.hpc, win);
    [mCtx, ~, ts] = meanTriggeredSignal(mu.ts(hpcPkIdx), mu.ts, mu.ctx, win);

    C = [C; mCtx];
    H = [H; mHpc];

end
%%
figure;
h = mean(H);
c = mean(C);

ax(1) = axes('Position', [.05 .475 .9 .425]);
ax(2) = axes('Position', [.05 .05 .9 .425]);
uistack(ax(1),'top');

line(ts, h, 'Color', 'r','Parent', ax(1));
line(ts, c, 'Color', 'b','Parent', ax(2));

set(ax(1), 'XtickLabel', {});

set(ax,'Xlim', [-.5 .5],'YTick', [], 'Xtick', [-.5:.1:.5]);


title(ax(1), sprintf('Thold %dms - %dms', thold * 1000), 'fontSize', 16);


% %%
% [~, ctxPkIdx] = findpeaks(mCtx);
% dPk = [diff(ts(ctxPkIdx)), 0];
% % close all;
% figure('Position', [450 750 800 350]); 
% 
% ax1 = subplot(211);
% [p,l] = error_area_plot(ts, mHpc, 1.96 * sHpc / sqrt( nBurst), 'parent', ax1);
% set(p, 'FaceColor', 'r', 'EdgeColor', 'none');
% set(l,'Color', 'k', 'LineWidth', 2);
% 
% for i = 1:numel(ctxPkIdx)
%     if ts(ctxPkIdx(i))<-.1 || ts(ctxPkIdx(i))>.3
%         continue
%     end
%     line( ts(ctxPkIdx(i)) * [1 1], [0 max(mHpc)], 'color', 'k');
%     if i==numel(ctxPkIdx)
%         continue;
%     end
%     text( mean( ts(ctxPkIdx([i,i+1]))) , max(mHpc) * 1.1, sprintf('%2.0f', 1000 * dPk(i)), 'fontsize', 16);
% end
% 
% title(regexprep(fName, '_', '  '), 'fontsize', 16);
% 
% ax2 = subplot(212);
% [p,l] = error_area_plot(ts, mCtx, 1.96 * sCtx / sqrt( nBurst), 'parent', ax2);
% set(p, 'FaceColor', 'b', 'EdgeColor', 'none');
% set(l,'Color', 'k', 'LineWidth', 2);
% 
% title(sprintf('thold:%2.0fms', thold*1000), 'fontsize', 16);
% 
% set( get(gcf,'Children'), 'XLim', win);
% %%
% 
% 
%    
% 
% 
% 
% %%
% idx = seg2binary(muBursts, mu.ts);
% line_browser(mu.ts, mu.hpc, 'color', 'k');
% line_browser(mu.ts, mu.hpc.*idx, 'color', 'r', 'parent', gca');
% 
% 
% %%
% [xc, l] = xcorr(mu.hpc .* idx, mu.ctx.*idx, 200);
% 
% close all;
% plot(l*5, xc);
