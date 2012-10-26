function e = generateFigure3(e)
open_pool;
%% Load Data for the figure
% dset = dset_load_all('spl11', 'day15', 'run');

if nargin==0 
    e = exp_load('/data/spl11/day15', 'epochs', 'run', 'data_types', {'clusters', 'pos'});
    e = process_loaded_exp2(e);
end

runRecon = exp_reconstruct(e,'run', 'structures', {'lCA1', 'rCA1'});

[pdf1, pdf2, isMovingBins] = compute_run_pdf(runRecon, e.run.pos);
[binDist, confMat] = compute_recon_distance(pdf1, pdf2);

confMat = normalize(confMat);
confMat(:,:,2) = confMat;
confMat(:,:,3) = confMat(:,:,1);
confMat = 1 - confMat;



%% Draw the figure
if exist('f', 'var'), delete( f( ishandle(f) ) ); end
if exist('ax', 'var'), delete( ax( ishandle(ax) ) ); end


f = figure('Position',  [139 263 1045 471]);
ax(1) = axes('Position', [.042 .065 .64 .89]);
plot_example_run_recon(pdf1, pdf2, runRecon(1).tbins(isMovingBins), ax(1))
set(ax(1), 'YTick', [1 2],'YTickLabels', {'Left', 'Right'});

ax(2) = axes('Position', [.72 .54 .20 .41]);
imagesc((1:31)/10, (1:31)/10, confMat, 'Parent', ax(2));
set(ax(2), 'Ydir', 'normal');

ax(3) = axes('Position', [.72 .05 .20 .41]);
[occ, cent] = hist(binDist, 0:30);
bar(cent, occ, 1,'Parent', ax(3));
set(ax(3),'YScale', 'log', 'XLim', [-1 31]);

%% Save the Figure
save_bilat_figure('figure3', f);


%%end
end

function [pdf1, pdf2, isMoving] =  compute_run_pdf(r,p)

    t = r(1).tbins;    
    vel = interp1(p.ts,  p.lv, t, 'nearest');
    
    isMoving = abs(vel)>.15;
    
    pdf1 = r(1).pdf(:, isMoving,:);
    pdf1(:,:,2) = pdf1(:,:,1);
    
    pdf2 = r(2).pdf(:, isMoving,:);
    tmp = pdf2(:,:,2);
    pdf2(:,:,2) = pdf2(:,:,3);
    pdf2(:,:,3) = tmp;
    
    
end
function plot_example_run_recon(pdf1, pdf2, t, ax)
   
    imagesc(t, .5:2.5, [pdf1; pdf2], 'Parent', ax);
    set(ax,'Xlim', [4463 4779])
    
end

function [binDist, confMat] = compute_recon_distance(pdf1, pdf2)
    [~, idx1] =  max( max(pdf1,[],3) );
    [~, idx2] =  max( max(pdf2,[],3) );
    
    binDist = abs(idx1 - idx2);
    confMat = confmat(idx1, idx2);

end

function c1 = compute_recon_corr(pdf1, pdf2)   
    c1 = corr_col(max(pdf1,[], 3), max(pdf2,[], 3));
end
