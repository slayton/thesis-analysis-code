function generateFigure2
%% Load all the data required for plotting!
open_pool;
%%
clear;

ripples = dset_load_ripples;

ripPhaseSleep = calc_bilateral_ripple_phase_diff(ripples.sleep);
ripFreqSleep = calc_bilateral_ripple_freq_distribution(ripples.sleep);

ripPhaseRun = calc_bilateral_ripple_phase_diff(ripples.run);
ripFreqRun = calc_bilateral_ripple_freq_distribution(ripples.run);

data = load('/data/thesis/bilateral_ripple_coherence.mat');
ripCohere = data.rippleCoherence;
ripCohere.sleep.shuffleCoherence = ripCohere.sleep.shuffleCoherence(1);
ripCohere.run.shuffleCoherence = ripCohere.run.shuffleCoherence(1);

clear data;

%% Close any existing figures
% close all;
%% Setup Figure

if exist('f2Handle', 'var'), delete( f2Handle( ishandle(f2Handle) ) ); end
if exist('axF2', 'var'), delete( axF2( ishandle(axF2) ) ); end

f2Handle = figure('Position', [650 50  581 492], 'NumberTitle','off','Name', 'Bilat Fig 2' );



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       A - Ripple Peak Triggered LFP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axF2(1) = axes('Position', [.055 .57 .35 .38], 'Color', 'k');


% rTrigLfp = calc_ripple_triggered_mean_lfp(ripples.sleep());
rTrigLfp = calc_ripple_triggered_mean_lfp(ripples.sleep([10:13]));

% error_area_plot(rTrigLfp.ts, rTrigLfp.meanLfp{1}, 'Color', [1 0 0 ], 'Parent', axF2(3));
line(rTrigLfp.ts, rTrigLfp.meanLfp{1}, 'Color', [1 0 0 ], 'Parent', axF2(1)); 
line(rTrigLfp.ts, rTrigLfp.meanLfp{2}, 'Color', [0 1 0 ], 'Parent', axF2(1));
set(axF2(1),'XLim', [-.075 .075], 'YTick', []);
t = title('Bon4 Rip trig LFP');
set(t,'Position', [0 200, 1]);
%plot_ripple_trig_lfp(rTrigLfp, axF2(3));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       B - Bilateral Ripple Peak Phase Distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axF2(2) = axes('Position', [.55 .55 .35 .38]);

freqBins = -(pi) : pi/8 : (pi + pi/8);

rose2(ripPhaseSleep.dPhase, freqBins, 'Parent', axF2(2));
title('Ripple Phase difference distribution', 'Parent', axF2(2));

% set(axF2(4), 'XLim', [-1.05 1.05] * pi , 'XTick', -pi:pi/2:pi);
% set(axF2(4), 'XTickLabel', {'-pi','-pi/2',  '0', 'pi/2', 'pi'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       C - Bilateral Ripple Mean Freq Distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axF2(3) = axes('Position', [.055 .065 .35 .38]);

freqBins = 150:3:225;
bilatFreqDistSleep = hist3([ripFreqSleep.base, ripFreqSleep.cont], {freqBins, freqBins});
bilatFreqDistRun = hist3([ripFreqRun.base, ripFreqRun.cont], {freqBins, freqBins});

% occ = smoothn(occ,1);
imagesc(freqBins, freqBins, bilatFreqDistSleep, 'Parent', axF2(3));

set(axF2(3),'Xlim', [150 225], 'YLim', [150 225], 'YDir', 'normal');
set(axF2(3),'XTick',150:25:225,'YTick', 150:25:225);
t = title('Bilateral Ripple Mean Freq Dist', 'Parent', axF2(3));
set(t,'Position', [187.5 225, 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       D - Bilateral Coherence Around Ripples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axF2(4) = axes('Position', [.55 .065 .35 .38]);

F = ripCohere.sleep.F;
mCoData = mean(ripCohere.sleep.rippleCoherence);
sCoData = std(ripCohere.sleep.rippleCoherence);
n = size(ripCohere.sleep.rippleCoherence,1);
nStd = 3;

mCoShuf = mean( ripCohere.sleep.shuffleCoherence{1} );
sCoShuf = std( ripCohere.sleep.shuffleCoherence{1} );

[p(1), l(1)] = error_area_plot(F, mCoData, nStd * sCoData / sqrt(n), 'Parent', axF2(4));
[p(2), l(2)] = error_area_plot(F, mCoShuf, nStd * sCoShuf / sqrt(n), 'Parent', axF2(4));
set(l(1), 'Color', [1 0 0], 'LineWidth', 1.5);
set(l(2), 'Color', [0 1 0], 'LineWidth', 1.5);

set(p(1), 'FaceColor', [1 0 0], 'edgecolor', 'none', 'facealpha', .3);
set(p(2), 'FaceColor', [0 1 0], 'edgecolor', 'none', 'facealpha', .3);
set(axF2(4),'Xlim', [0 400], 'XTick', 0:100:400);
t = title('Bilateral Ripple Coherence', 'Parent', axF2(4));
set(t,'Position', [200 .5 1]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       E- Bilateral Freq Distribution : RUN VS SLEEP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
fig2E = figure;
ax2E = axes(); hold on;

dataS = bilatFreqDistSleep;
dataR = bilatFreqDistRun;

% dataS = dataS ./ max(dataS(:));
% dataR = dataR ./ max(dataR(:));

dataR = smoothn(dataR,2);
dataS = smoothn(dataS,2);

tholdS = quantile( dataR(:), .5 );
tholdR = quantile( dataS(:), .5 );
 
c{1} = contourc(freqBins, freqBins, bilatFreqDistSleep, [0 0] + tholdS); hold on;
c{2} = contourc(freqBins, freqBins, bilatFreqDistRun, [0 0] + tholdR);

for i = 1:numel(c)
    result = parse_contour_matrix( c{i} );
    cont(i) = result(1);
end
% cSleep = contour(freqBins, freqBins, bilatFreqDistSleep, 3); hold on;
% cRun = contour(freqBins, freqBins, bilatFreqDistRun, 3);
% nPt = size(cSleep,2);
% 
% line(cSleep(2,1:(nPt/2)), cSleep( (1 + nPt/2):nPt),'linestyle', 'none', 'marker','.', 'color','r');
% line(cRun(,1:(nPt/2)), cRun( (1 + nPt/2):nPt), 'linestyle', 'none', 'marker','.', 'color','k');

for i = 1:numel(cont)
    [e(i).Z, e(i).A, e(i).B, e(i).ALPHA] = fitellipse( [cont(i).x; cont(i).y] );
    [el(i).x, el(i).y] = ellipse_points( e(i).Z, e(i).A, e(i).B, e(i).ALPHA );
end

p(1) = patch(el(1).x, el(1).y, [1 .5 .5]);
p(2) = patch(el(2).x, el(2).y, [.5 .5 1]);

set(p(1), 'EdgeColor', [.7 0 0]);
set(p(2), 'EdgeColor', [0 0 .7]);
xlabel('Source Ripple Freq (Hz)');
ylabel('Test Ripple Freq (Hz)');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      F - Bilateral Ripple Coherence : RUN VS SLEEP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
fig2F = figure;
ax2F = plotyy(1,1,1,1);

F = ripCohere.sleep.F;
mCoSleep = mean(ripCohere.sleep.rippleCoherence);
mCoRun = mean(ripCohere.run.rippleCoherence);

sCoSleep = std(ripCohere.sleep.rippleCoherence);
sCoRun = std(ripCohere.run.rippleCoherence);

n = size(ripCohere.sleep.rippleCoherence,1);
nStd = 3;

[p(1), l(1)] = error_area_plot(F, mCoSleep, nStd * sCoSleep / sqrt(n), 'Parent', ax2F(1));
[p(2), l(2)] = error_area_plot(F, mCoRun, nStd * sCoRun / sqrt(n), 'Parent', ax2F(1));

% set(l(1), 'Color', [1 0 0], 'LineWidth', 1.5);
% set(l(2), 'Color', [0 0 1], 'LineWidth', 1.5);

delete(l(1:2));

set(ax2F,'Xlim', [0 400], 'XTick', 0:100:400); 

set(p(1), 'FaceColor', [1 .7 .7], 'edgecolor', 'none');
set(p(2), 'FaceColor', [.7 .7 1], 'edgecolor', 'none');
uistack(p(2), 'top')

rError = (nStd * sCoRun)/sqrt(n);
sError = (nStd * sCoSleep)/sqrt(n);

rCorr{1} = mCoRun + rError;
rCorr{2} = mCoRun - rError;

sCorr{1} = mCoSleep + sError;
sCorr{2} = mCoSleep - sError;


X = [F; flipud(F)];
Y = [sCorr{2}./rCorr{1}, fliplr(sCorr{1}./rCorr{2})]';

p(3) = patch(X,Y, [ .5 .7 .7] ,'Parent', ax2F(2));
set(p(3),'edgecolor', 'none')

%line(F, mCoSleep./mCoRun, 'Color', [0 0 0 ], 'Parent', ax2F(2), 'linewidth', 1.5);

set(ax2F,'Xlim', [0 400], 'XTick', 0:100:400, 'YColor', 'k');
set(ax2F(1),'YLim', [.15 .5], 'YTick', [0:.1:.5], 'box', 'off');
set(ax2F(2), 'Ylim', [.9 2.1]);

uistack(ax2F(1),'top');
set(ax2F(2),'Color', 'w');
set(ax2F(1),'Color', 'none');
ylabel(ax2F(1), 'Ripple Coherence');
ylabel(ax2F(2), 'Sleep to Run Ratio');
xlabel(ax2F(1), 'Frequency Hz');
%%

%% Save the figure
save_bilat_figure('figure2-abcd', f2Handle);
save_bilat_figure('figure2-e', fig2E);
save_bilat_figure('figure2-f', fig2F);
% 
% saveDir = '/data/bilateral/figures';
% figName = ['figure2-', datestr(now, 'yyyymmdd')];
% 
% saveFigure(fHandle, saveDir, figName, 'png', 'fig', 'svg');
% save(fullfile(saveDir, 'figure2-data.mat'))
%%
end