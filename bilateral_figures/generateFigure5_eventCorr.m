function generateFigure5_eventCorr(ep)
%%

eList = dset_list_epochs(ep);
nEpoch = size(eList,1);

for i = 1:nEpoch
    d = dset_load_all( eList{i,:} );
    
    stats(i) = calc_bilateral_replay_corr(d, 0);
    
end

%%
q = stats(1).quantiles;
qReal = cell2mat( {stats.realCorrQuantiles}');
qShuf = cell2mat( {stats.shufCorrQuantiles}');

f = figure; 
tmp = [.1 .25 .5 .75 .9];
for i = 1:4;
    subplot(1,4,i);
    set(gca,'NextPlot', 'add');
    
    r = qReal(:, q == tmp(i) );
    s = qShuf(:, q == tmp(i) );

%     figure; axes('NextPlot', 'add');

    plot(1:2, [r,s], 'color', [.4 .4 .4]);
    boxplot([r,s]); 
    title( sprintf('Q:%2.2f', tmp(i)))
    
    fprintf('p:%3.4g\tp:%3.4g\n', [ranksum(r,s, 'tail', 'right') signrank(r,s, 'tail', 'right')]);
end

set( get(gcf,'children'), 'YLim', [-.5 1], 'XTick', [1 2], 'XTickLabel', {'Real', 'Shuf'});

figName = sprintf('Figure5-EventCorr-boxplot-%s',ep);
save_bilat_figure(figName, f);


%%
end