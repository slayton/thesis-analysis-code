function generateFigure4
%% Load all the data required for plotting!
open_pool;
%%
clear;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           LOAD THE DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
runEpochs = dset_list_epochs('run');

i = 1;
% for i = 1:numel(runReconFiles)
    
    dset = dset_load_all(runEpochs{i,1}, runEpochs{i,2}, runEpochs{i,3});    

    lIdx = strcmp({dset.clusters.hemisphere}, 'left');
    rIdx = strcmp({dset.clusters.hemisphere}, 'right');
    
    if sum(lIdx) > sum(rIdx)
        clIdx{1} = lIdx;
        clIdx{2} = rIdx;
    else
        clIdx{1} = rIdx;
        clIdx{2} = lIdx;
    end
    [~, reconSimp(1)] = dset_calc_replay_stats(dset, clIdx{1}, [], [], 1, 'simple');
    [~, reconSimp(2)] = dset_calc_replay_stats(dset, clIdx{2}, [], [], 1, 'simple');

    clear st rp;
    for iii = 1:2
        [st(iii), rp(iii)] = dset_calc_replay_stats(dset, clIdx{iii}, [], [],1);
    end
    
%     score1 = stats(1).score2;
%     score2 = stats(2).score2;
%     [~, trajIdx] = max( max(score1, score2), [], 2);
    
% get the indecies of the timebins with spikes in both hemispheres
    
    lSpikeIdx = logical( sum(reconSimp(1).spike_counts) );
    rSpikeIdx = logical( sum(reconSimp(2).spike_counts) );
    
    % get the indecies of the pdf that are within a multi-unit burst
    muTs = reconSimp(1).tbins;
    events = dset.mu.bursts;
    burstIdx = arrayfun(@(x,y) ( muTs >= x & muTs <= y ), events(:,1), events(:,2), 'UniformOutput', 0 );
    burstIdx = sum( cell2mat(burstIdx'), 2);
 
    replayIdx = burstIdx & logical( sum( reconSimp(1).spike_counts ) )'  & logical( sum( reconSimp(2).spike_counts) )';

    pdf1 = reconSimp(1).pdf(:, replayIdx);
    pdf2 = reconSimp(2).pdf(:, replayIdx);

    nSpike{1} = sum( rp(1).spike_counts(:, replayIdx));
    nSpike{2} = sum( rp(2).spike_counts(:, replayIdx));
    
% Compute the distances between the peaks od the pdfs
    [~, idx1] = max(pdf1);
    [~, idx2] = max(pdf2);
    %binDist = abs(idx1 - idx2);
    binDist = calc_posidx_distance(idx1, idx2, dset.clusters(1).pf_edges);
    
    %compute the confusion matrix
    confMat = confmat(idx1, idx2);
    confMat(:, sum(confMat)==0) = 1;
    confMat = normalize(confMat);
    confMat(:,:,2) = confMat;
    confMat(:,:,3) = confMat(:,:,1);
    confMat = 1 - confMat;
    
    % Compute the correlations between the pdfs
    replayCorr = corr_col(pdf1, pdf2);  
    
% Compute the shuffle distributions
    nShuffle = 100;    
    colCorrShuffle = [];
    binDistShuffle = [];
   
    for i = 1:nShuffle
        randIdx = randsample( size(pdf1,2), size(pdf1,2), 0);
        colCorrShuffle = [ colCorrShuffle, corr_col( pdf1, pdf2(:, randIdx) ) ];
        binDistShuffle = [ binDistShuffle, calc_posidx_distance(idx1, idx2(randIdx), dset.clusters(1).pf_edges);];
    end
    
% compute the bilateral multi-unit xcorr

xcWin = .25;
muTs = dset.mu.timestamps;
muDt = mean( diff( muTs ));

muBurstIdx = arrayfun(@(x,y) ( muTs >= x-xcWin & muTs <= y+xcWin ), events(:,1), events(:,2), 'UniformOutput', 0 );
muBurstIdx = logical( sum( cell2mat(muBurstIdx'), 2) );

[muXc, lags] = xcorr(dset.mu.rateL .* muBurstIdx, dset.mu.rateR .* muBurstIdx, ceil(xcWin/muDt), 'coeff');
lags = lags * mean( diff( muTs ) );


pdfComp = dset_compare_bilateral_pdf_by_percent_cell_active(dset, st, reconSimp);
    
    
%% Draw the figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Draw the figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if exist('fHandle', 'var'), delete( fHandle( ishandle(fHandle) ) ); end
if exist('axHandle', 'var'), delete( axHandle( ishandle(axHandle) ) ); end
axHandle = [];
fHandle = figure('Position',  [350 250 650 620], 'Name', dset_get_description_string(dset) );
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      A,B,C - Replay Examples
% Bon3-2 Examples: [147 159*] 100, 111, 146, 147, 159, 172?!?, 209
% Bon3-4 Examples: 66, 94, *124*, 147, 159L
% Bon4-2 Examples: 096, 104-3, 115-1, 120-2, 126, 130
% Bon5-2 Examples: 093, 102, 115
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nAx = 6;
axHandle(1) = axes('Position', [.0328 .53 .1311 .44]);
axHandle(2) = axes('Position', [.1639 .53 .1311 .44]);
axHandle(3) = axes('Position', [.3605 .53 .1311 .44]);
axHandle(4) = axes('Position', [.4916 .53 .1311 .44]);
axHandle(5) = axes('Position', [.6882 .53 .1311 .44]);
axHandle(6) = axes('Position', [.8193 .53 .1311 .44]);

%e = dset.mu.bursts(124,:);

eIdxList = [159 172 111];
trajList = [2 1 2];
tbins = linspace(-.1, .1, 11);
for ii = 1:3
    eIdx = eIdxList(ii);
    traj = trajList(ii);
    
    eTime = mean(dset.mu.bursts(eIdx,:));
    xcWin = .1;
    tIdx = rp(1).tbins > (eTime - xcWin) & rp(1).tbins < (eTime + xcWin);
    
    imagesc(tbins, rp(1).pbins{traj},  rp(1).pdf{traj}(:,tIdx), 'Parent', axHandle((ii-1)*2 + 1) );
    imagesc(tbins, rp(1).pbins{traj},  rp(2).pdf{traj}(:,tIdx), 'Parent', axHandle((ii-1)*2 + 2) );
end

set(axHandle(1:nAx), 'YTick', [])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       C - Bilateral Multi-unit xcorr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nAx = nAx + 1;
axHandle(nAx) = axes('Position', [.0305 .1226 .2685 .2767]);
area(lags, muXc, 0);
set(axHandle(nAx), 'XLim', [-.25 .25], 'YLim', [.15 .75]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       D - Distribution of Column Correlations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nAx = nAx+1;
axHandle(nAx) = axes('Position', [.3622 .1226 .2685 .2767]);
bins = -1:.025:1;

[~, pCorr1] = kstest2(replayCorr, colCorrShuffle, .05, 'smaller');
[~, pCorr2] = cmtest2(replayCorr, colCorrShuffle);

[occRealCorr, cent] = hist(replayCorr, bins); 
[occShufCorr]       = hist(colCorrShuffle, bins);

occRealCorr = smoothn(occRealCorr, 3, 'correct', 1);
occShufCorr = smoothn(occShufCorr, 3, 'correct', 1);

occRealCorr  = occRealCorr./sum(occRealCorr);
occShufCorr  = occShufCorr./sum(occShufCorr);

line(cent, occRealCorr, 'color', 'r','LineWidth', 2, 'parent', axHandle(nAx));
line(cent, occShufCorr, 'color', 'g','LineWidth', 2, 'parent', axHandle(nAx));

set(axHandle(nAx),'XLim', [-1.05 1.1], 'XTick', [-1:.5:1]);
title( sprintf('PDF Correlation p<%0.2g %02.g ', pCorr1, pCorr2) ); 
nAx = nAx+1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       E - Distance between the modes of the two pdfs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axHandle(nAx) = axes('Position', [.6905 .1226 .2685 .2767]);

[~, pDist1] = kstest2(binDist, binDistShuffle, .05, 'larger');
[~, pDist2] = cmtest2(binDist, binDistShuffle);

[occRealDist, cent] = hist(binDist, 0:31);
[occShufDist] = hist(binDistShuffle, 0:31);

occRealDist = interp1(cent, occRealDist, 0:.25:31);
occShufDist = interp1(cent, occShufDist, 0:.25:31);
cent = 0:.25:31;

occRealDist = smoothn(occRealDist, 2, 'correct', 1);
occShufDist = smoothn(occShufDist, 2, 'correct', 1);

occRealDist  = occRealDist./sum(occRealDist);
occShufDist  = occShufDist./sum(occShufDist);

line(cent/10, occRealDist, 'color', 'r','LineWidth', 2, 'parent', axHandle(nAx));
line(cent/10, occShufDist, 'color', 'g','LineWidth', 2, 'parent', axHandle(nAx));

set(axHandle(nAx), 'XLim', [-.1 3]);
title( sprintf('\\Delta pos p<%0.2g %02.g ', pDist1, pDist2) );

nAx = nAx+1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   Shift the axes up
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set(axHandle,'Units', 'pixels');
set(gcf,'Position', [467 159 650 934]);
for i = 1:numel(axHandle)
   set(axHandle(i), 'Position', get(axHandle(i), 'Position') + [0 300 0 0]);
end
set(axHandle,'Units', 'normal');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Distribution of Correlations by Percent Cells active
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axHandle(nAx) = axes('position', [.1653 .1478 .2685 .1837]);
d1 = pdfComp.highPerCorr; 
d2 = pdfComp.lowPerCorr;
bins = [-5:.05:1];
[h1, cent] = hist(d1, bins);
[h2, ~] = hist(d2, bins);

line(cent, smoothn(h1 ./ sum(h1), 1.5, 'correct', 1), 'color', 'b', 'Parent', axHandle(nAx), 'linewidth', 2);
line(cent, smoothn(h2 ./ sum(h2), 1.5, 'correct', 1), 'color', 'k', 'Parent', axHandle(nAx), 'linewidth', 2);

set(axHandle(nAx), 'XLim', [-.5 1]);
nAx = nAx+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Distribution of Distances by Percent Cells active
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axHandle(nAx) = axes('position', [.5622 .1478 .2685 .1837]);
d1 = pdfComp.highPerDist; 
d2 = pdfComp.lowPerDist;
bins = [0:45];
[h1, cent] = hist(d1, bins);
[h2, ~] = hist(d2, bins);

line(cent, smoothn(h1 ./ sum(h1), 2, 'correct', 1), 'color', 'b', 'Parent', axHandle(nAx), 'linewidth', 2);
line(cent, smoothn(h2 ./ sum(h2), 2, 'correct', 1), 'color', 'k', 'Parent', axHandle(nAx), 'linewidth', 2);

set(axHandle(nAx), 'XLim', [0 45]);
nAx = nAx+1;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %           Correlation plots by percent cells  BOXPLOT
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% axHandle(nAx) = axes('position', [.0305 .208 .1931 .16]);
% d1 = pdfComp.highPerCorr; 
% d2 = pdfComp.lowPerCorr;
% vals = [d1; d2];
% cat = [ones(size(d1)); zeros(size(d2))];
% boxplot(vals, cat, 'Parent', axHandle(nAx));
% 
% nAx = nAx+1;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %           Correlation plots by percent cells  E-CDF
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% axHandle(nAx) = axes('position', [.2855 .208 .1931 .16]);
% ecdf(axHandle(nAx), d1 ); set(get(axHandle(nAx),'Children'), 'Color', 'r'); hold on;
% ecdf(axHandle(nAx), d2 );
% 
% nAx = nAx+1;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %           Distance plots by percent cells  BOXPLOT
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% axHandle(nAx) = axes('position', [.5405 .208 .1931 .16]);
% 
% d1 = pdfComp.highPerDist;
% d2 = pdfComp.lowPerDist;
% vals = [d1; d2];
% cat = [ones(size(d1)); zeros(size(d2))];
% boxplot(vals, cat, 'Parent', axHandle(nAx));
% 
% nAx = nAx+1;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %           Distance plots by percent cells  ECDF
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% axHandle(nAx) = axes('position', [.7685 .208 .1931 .16]);
% ecdf(axHandle(nAx), d1 ); set(get(axHandle(nAx),'Children'), 'Color', 'r'); hold on;
% ecdf(axHandle(nAx), d2 );


%% Save the Figure
 save_bilat_figure('figure4-v2', fHandle);


end


