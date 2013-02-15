%%
clearvars  -except MultiUnit LFP
win = 1;
N = numel(MultiUnit);

xcAll = nan(N, 401);


for i = 1 : N
   mu = MultiUnit{i};
   
   bursts = find_mua_bursts(mu); 
   bIdx = seg2binary(bursts, mu.ts);
   
   xcAll(i,:) = xcorr(mu.ctx, mu.hpc, 200, 'coeff');
   
end
%%

ts = -1:.005:1;

figure('Position', [360 440 580 260]);
ax = axes('FontSize', 14, 'NextPlot', 'add');
plot([0 0], minmax(mean(xcAll)), 'color', [.5 .5 .5]);
plot(ts, mean( xcAll ));
title('RSX - HPC MU XCorr');
ylabel('Correlation Coefficient');
xlabel('Time Lag (s)');

plot2svg('/data/HPC_RSC/mu_rate_hpc_rsc_xcorr.svg',gcf);