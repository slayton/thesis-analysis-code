function [e data] = generateFigure3_helper(e)
open_pool;
%% Load Data for the figure
% dset = dset_load_all('spl11', 'day15', 'run');
nargin
if nargin==0 
    e = exp_load('/data/spl11/day15', 'epochs', 'run', 'data_types', {'clusters', 'pos'});
    e = process_loaded_exp2(e);
end

runRecon = exp_reconstruct(e,'run', 'structures', {'lCA1', 'rCA1'});
pdf1 = max(runRecon(1).pdf,[],3);
pdf2 = max(runRecon(2).pdf,[],3);

[pdf1Run, pdf2Run, isMovingBins] = fig3_compute_run_pdf(runRecon, e.run.pos);
pdf1Run = max(pdf1Run,[],3);
pdf2Run = max(pdf2Run,[],3);
nBinsMoving = sum(isMovingBins);

%% Compute the Column by Column correlation
smPdf1 = smoothn(pdf1Run, [3 0], 'correct', 1);
smPdf2 = smoothn(pdf2Run, [3 0], 'correct', 1);
colCorr = corr_col(smPdf1, smPdf2);

%% Compute the distances between the modes of the columns
[~, idx1] =  max( max(pdf1Run,[],3) );
[~, idx2] =  max( max(pdf2Run,[],3) );

binDist = abs(idx1 - idx2);
confMat = confmat(idx1, idx2);

% colCorr = compute_recon_corr(pdf1Run, pdf2Run);
nShuffle = 250;

medDist = median(binDist);
medCorr = nanmedian(colCorr);

medDistShuff = zeros(nShuffle,1);
medCorrShuff = zeros(nShuffle,1);

colCorrShuff = [];
binDistShuff = [];

for iShuffle = 1:nShuffle
    
    shuffIdx = randsample( nBinsMoving, nBinsMoving, 1);
    binDistShuff = [binDistShuff, abs( idx1 - idx2(shuffIdx) )];
    colCorrShuff = [colCorrShuff, corr_col( pdf1Run, pdf2Run(:, shuffIdx) )];
    
    medDistShuff(iShuffle) = median(binDistShuff);
    medCorrShuff(iShuffle) = nanmedian( colCorrShuff);

end    
    
confMat = normalize(confMat);
confMat(:,:,2) = confMat;
confMat(:,:,3) = confMat(:,:,1);
confMat = 1 - confMat;

%% Draw the figure

if exist('f', 'var'), delete( f( ishandle(f) ) ); end
if exist('ax', 'var'), delete( ax( ishandle(ax) ) ); end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      A - Bilateral Reconstruction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = figure('Position',  [190 75 550 920]);
ax(1) = axes('Position', [.0745 .74 .8127 .1991]);
fig3_example_run_recon( pdf1Run, pdf2Run,[] , ax(1))
set(ax(1), 'XLim', [181 437], 'XTick', []);
%set(ax(1));
title('Reconstruction of Run Segments');

ax(6) = axes('Position', [.0766 .4657 .3663 .2179]);
fig3_example_run_recon( pdf1, pdf2, runRecon(1).tbins, ax(6));
set(ax(6),'Xlim', [4473.6 4482.9]);
title('Example Lap');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       B - Confusion Matrix   B2 - color bar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax(2) = axes('Position', [.5185 .4646 .3663 .2179]);
imagesc((1:31)/10, (1:31)/10, confMat, 'Parent', ax(2));
set(ax(2), 'Ydir', 'normal');
title('Confusion Matrix','Position', [1.6 3.1 1.01]);

ax(3) = axes('Position', [.8968 .4646 .03 .2179]);
scaleImg = 1 - repmat(linspace(0, 1, 20)', [1,1,3]);
image(1, linspace(0,1,20), scaleImg, 'Parent', ax(3));
set(ax(3), 'YDir', 'normal', 'yaxislocation', 'right', 'XTick', [], 'XLim', [.5 1.5]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       C - Distribution of Column Correlations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax(4) = axes('Position', [.0766 .2511 .3663 .15]);
bins = -3:.1:1;
[occ, cent] = hist(colCorr, bins); 
occ = occ./sum(occ);
bar(cent, occ, 1,'Parent', ax(4));
set(ax(4),'XLim', [-1.05 1.1], 'XTick', [-1:.5:1]);
title('PDF Correlation', 'Position', [0 1 1]); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       D - Distance between the modes of the two pdfs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax(5) = axes('Position', [.5185 .2511 .3663 .15]);
[occ, cent] = hist(binDist, 0:31);
occ = occ./sum(occ);
bar(cent/10,occ, 1,'Parent', ax(5)); 
set(ax(5), 'XLim', [-.1 3]);
title('\Delta pos of Pdf mode', 'Position', [1.5 1 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       E - Example shuffle of correlations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax(7) = axes('Position', [.0766 .0641 .3663 .1305]); % axes 6 is up in the recon
bins = -3:.1:1;
[occ, cent] = hist(colCorrShuff, bins);
occ = occ./sum(occ);
bar(cent, occ, 1,'Parent', ax(7));
set(ax(7),'XLim', [-1.05 1.1], 'XTick', [-1:.5:1]);
title('Shuff PDF Correlation', 'Position', [0 1 1]); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       F - Shuffle of distances
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax(8) = axes('Position', [.5185 .0641 .3663 .1305]); % axes 6 is up in the recon

[occ, cent] = hist(binDistShuff, 0:31); 
occ = occ./sum(occ);
bar(cent/10,occ, 1,'Parent', ax(8));
set(ax(8), 'XLim', [-.1 3]);
title('\Delta pos of Shuff Pdf mode', 'Position', [1.5 .1 1]);

%% Save the Figure
save_bilat_figure('figure3', f);


%%end
end


