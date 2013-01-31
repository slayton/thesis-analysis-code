clear;
ep = 'sleep3';
edir = '/data/gh-rsc1/day18';
fName = sprintf('MU_HPC_RSC_%s.mat', upper(ep));
mu = load( fullfile(edir, fName) );
mu = mu.mu;

b = find_mua_bursts(mu);
%%

bLen = diff(b, [], 2);

thold = .25;
idx = find( bLen > thold );
nnz(idx)
hpcPkIdx = [];

for i = 1:numel(idx)
   burst = b(idx(i),:);
   
   startIdx = find( burst(1) == mu.ts, 1, 'first');
   
   r = mu.hpc( mu.ts>=burst(1) & mu.ts <= burst(2) );
   
   [~, pk] = findpeaks(r);
   pk = pk + startIdx -1;
   hpcPkIdx = [hpcPkIdx, pk(1)];
   
end
%%
win = [-.15 .35];
[mHpc, ~, ts] = meanTriggeredSignal(mu.ts(hpcPkIdx), mu.ts, mu.hpc, win);
[mCtx, ~, ts] = meanTriggeredSignal(mu.ts(hpcPkIdx), mu.ts, mu.ctx, win);


[~, ctxPkIdx] = findpeaks(mCtx);
dPk = [diff(ts(ctxPkIdx)), 0];
% close all;
figure('Position', [450 750 800 350]); 

subplot(211);
plot(ts, mHpc);
for i = 1:numel(ctxPkIdx)
    if ts(ctxPkIdx(i))<-.1 || ts(ctxPkIdx(i))>.3
        continue
    end
    line( ts(ctxPkIdx(i)) * [1 1], [0 max(mHpc)], 'color', 'k');
    if i==numel(ctxPkIdx)
        continue;
    end
    text( mean( ts(ctxPkIdx([i,i+1]))) , max(mHpc) * .75, sprintf('%2.0f', 1000 * dPk(i)), 'fontsize', 12);
end

title(regexprep(fName, '_', '  '), 'fontsize', 16);

subplot(212);
plot(ts, mCtx,'r');
title(sprintf('thold:%2.0fms', thold*1000), 'fontsize', 16);

set( get(gcf,'Children'), 'XLim', win);
%%


   



%%
line_browser(mu.ts, mu.hpc, 'color', 'k');
line_browser(mu.ts(idx), mu.hpc(idx), 'color', 'r', 'parent', gca');

