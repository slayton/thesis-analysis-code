function [t1 t2 t3 r1 r2 r3] =  generateFigure5_replay_stats(ep)
%%


eList = dset_list_epochs(ep);
nEpoch = size(eList,1);


for i = 1:nEpoch
    d = dset_load_all( eList{i,:} );
    
    lIdx = strcmp({d.clusters.hemisphere}, 'left');
    rIdx = strcmp({d.clusters.hemisphere}, 'right');
    
 
    args = {'time_win', d.epochTime, 'tau', .02};
    
    recon(1) = dset_reconstruct(d.clusters(lIdx), args{:} );
    recon(2) = dset_reconstruct(d.clusters(rIdx), args{:} );
    
    [cHigh(i), cLow(i), stats(i)] = dset_compare_bilateral_pdf_by_n_mu_spike(d, recon);
    
    
end

%%

%%
h = cHigh;
l = cLow;
s = stats;

C = {stats.colCorr};
N = {stats.nSpike};

hh = [];
ll = [];

hhh = [];
lll = [];
for i = 1:nEpoch
    
    c = C{i};
    n = N{i};
    
    quantile(n, .5)
    idxM = n < quantile(n, .5);
    idxL = n < quantile(n, .33);
    idxH = n > quantile(n, .66);
    
    ll(end+1) = mean(c(idxL));
    hh(end+1) = mean(c(idxH));   
    
    lll(end+1) = mean(c(idxM));
    hhh(end+1) = mean(c(~idxM));
 
end


fig = figure('Name', ep);
subplot(131);
boxplot([l', h']);
set(gca,'XTick', [1 2], 'XTickLabel', {'<25%', '>75%'});
[~, t1] = ttest2(h, l, .05, 'right');
r1 = ranksum(h, l, 'tail', 'right');
title( sprintf('%2.3g %2.3g', [t1, r1]))

subplot(132);
boxplot([ll', hh']); hold on;
set(gca,'XTick', [1 2], 'XTickLabel', {'<33%', '>66%'});
[~, t2] = ttest2(hh, ll, .05, 'right');
r2 = ranksum(hh, ll, 'tail', 'right');
title( sprintf('%2.3g %2.3g', [t2, r2]))


subplot(133);
boxplot([lll', hhh']); hold on;
set(gca,'XTick', [1 2], 'XTickLabel', {'<50%', '>50%'});
[~, t3] = ttest2(hhh, lll, .05, 'right');
r3 = ranksum(hhh, lll, 'tail', 'right');
title( sprintf('%2.3g %2.3g', [t3, r3]))

set( get(gcf,'Children'), 'YLim', [-.1 1]);

figName = sprintf('Fig5_replay_event_corr_by_nSpike_mu%s', ep);
save_bilat_figure(figName, fig);

%%


%%
end
