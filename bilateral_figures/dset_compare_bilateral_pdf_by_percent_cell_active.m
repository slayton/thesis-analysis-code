function results = dset_compare_bilateral_pdf_by_percent_cell_active(dset, st, reconSimp)

per1 = st(1).percentCells; 
per2 = st(2).percentCells; 

nSpike1 = sum(reconSimp(1).spike_counts);
nSpike2 = sum(reconSimp(2).spike_counts);

bursts = dset.mu.bursts;
nBurst = size(bursts,1);

posDist = [];
eventCorr = nan(nBurst,1);

for i = 1:nBurst
    
    idx = reconSimp(1).tbins >= bursts(i,1) & reconSimp(1).tbins <= bursts(i,2) & logical(nSpike1)' & logical(nSpike2)';
    
    [~, p1] = max( reconSimp(1).pdf(:,idx));
    [~, p2] = max( reconSimp(2).pdf(:,idx));
    
    posDist = [posDist, calc_posidx_distance(p1, p2, dset.clusters(1).pf_edges)];
    eventCorr(i) = mean( corr_col( reconSimp(1).pdf(:, idx), reconSimp(2).pdf(:, idx) ) );  

end
validIdx = ~isnan(eventCorr);
per1 = per1(validIdx);
per2 = per2(validIdx);


thL1 = median(per1);
thL2 = median(per2);

thH1 = median(per1);
thH2 = median(per2);

idxLow = st(1).percentCells < thL1 & st(2).percentCells < thL2;
idxHigh = st(1).percentCells >= thH1 & st(2).percentCells >= thH2;

%% - Compute the distances between the PDF based upon % of cells active
highPerDist = posDist(idxHigh);
lowPerDist = posDist(idxLow);

highPerCorr = eventCorr(idxHigh);
lowPerCorr = eventCorr(idxLow);


[~, results.kstest_corr] = kstest2(highPerCorr, lowPerCorr, .05, 'smaller');
[~, results.cmtest_corr] = cmtest2(highPerCorr, lowPerCorr);

[~, results.kstest_dist] = kstest2(highPerDist, lowPerDist, .05, 'larger');
[~, results.cmtest_dist] = cmtest2(highPerDist, lowPerDist);

results.highPerDist = highPerDist';
results.lowPerDist = lowPerDist';

results.highPerCorr = highPerCorr;
results.lowPerCorr = lowPerCorr;

