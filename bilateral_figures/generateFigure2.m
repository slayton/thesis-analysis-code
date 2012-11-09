function generateFigure2
%% Load all the data required for plotting!
open_pool;
%%
clear;
%%
ripples = dset_load_ripples;

ripPhaseRun = calc_bilateral_ripple_phase_diff(ripples.run);
ripFreqRun = calc_bilateral_ripple_freq_distribution(ripples.run);

data = load('/data/thesis/bilateral_ripple_coherence.mat');
ripCohere = data.rippleCoherence;
ripCohere.sleep.shuffleCoherence = ripCohere.sleep.shuffleCoherence(1);
clear data;

%% Close any existing figures
close all;
%% Setup Figure

if exist('f2Handle', 'var'), delete( f2Handle( ishandle(f2Handle) ) ); end
if exist('axF2', 'var'), delete( axF2( ishandle(axF2) ) ); end

f2Handle = figure('Position', [650 50  581 492], 'NumberTitle','off','Name', 'Bilat Fig 2' );



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       A - Ripple Peak Triggered LFP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axF2(1) = axes('Position', [.05 .54 .35 .38], 'Color', 'k');


% rTrigLfp = calc_ripple_triggered_mean_lfp(ripples.run());
rTrigLfp = calc_ripple_triggered_mean_lfp(ripples.run([2 10]));

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
axF2(2) = axes('Position', [.55 .50 .35 .38]);

bins = -(pi) : pi/8 : (pi + pi/8);

rose2(ripPhaseRun.dPhase, bins, 'Parent', axF2(2));
title('Ripple Phase difference distribution', 'Parent', axF2(2));

% set(axF2(4), 'XLim', [-1.05 1.05] * pi , 'XTick', -pi:pi/2:pi);
% set(axF2(4), 'XTickLabel', {'-pi','-pi/2',  '0', 'pi/2', 'pi'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       C - Bilateral Ripple Mean Freq Distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axF2(3) = axes('Position', [.05 .05 .35 .38]);

bins = 150:3:225;
occ = hist3([ripFreqRun.base, ripFreqRun.cont], {bins, bins});
% occ = smoothn(occ,1);
imagesc(bins, bins, occ, 'Parent', axF2(3));

set(axF2(3),'Xlim', [150 225], 'YLim', [150 225], 'YDir', 'normal');
t = title('Bilateral Ripple Mean Freq Dist', 'Parent', axF2(3));
set(t,'Position', [187.5 225, 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       D - Bilateral Coherence Around Ripples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axF2(4) = axes('Position', [.55 .05 .35 .38]);

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

%% Save the figure
save_bilat_figure('figure2', f2Handle);
% 
% saveDir = '/data/bilateral/figures';
% figName = ['figure2-', datestr(now, 'yyyymmdd')];
% 
% saveFigure(fHandle, saveDir, figName, 'png', 'fig', 'svg');
% save(fullfile(saveDir, 'figure2-data.mat'))
%%
end