function generateFigure2
%% Load all the data required for plotting!
open_pool;
%%
clear;
%%
ripples = dset_load_ripples;

ripPhaseRun = calc_bilateral_ripple_phase_diff(ripples.run);
ripFreqRun = calc_bilateral_ripple_freq_distribution(ripples.run);

close all;
%% Setup Figure

fHandle = figure('Position', [650 50  825 275], 'NumberTitle','off','Name', 'Bilat Fig 2' );
ax = [];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       C - Ripple Peak Triggered LFP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rTrigLfp = calc_ripple_triggered_mean_lfp(ripples.run());
rTrigLfp = calc_ripple_triggered_mean_lfp(ripples.run([2 10]));

if numel(ax) > 0 && ishandle(ax(1)),   delete(ax(1)); end

ax(1) = axes('Position', [.05 .125 .28 .80], 'Color', 'k');
% error_area_plot(rTrigLfp.ts, rTrigLfp.meanLfp{1}, 'Color', [1 0 0 ], 'Parent', ax(3));
line(rTrigLfp.ts, rTrigLfp.meanLfp{1}, 'Color', [1 0 0 ], 'Parent', ax(1)); 
line(rTrigLfp.ts, rTrigLfp.meanLfp{2}, 'Color', [0 1 0 ], 'Parent', ax(1));
set(ax(1),'XLim', [-.075 .075], 'YTick', []);
t = title('Bon4 Rip trig LFP');
set(t,'Position', [0 200, 1]);
%plot_ripple_trig_lfp(rTrigLfp, ax(3));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       D - Bilateral Ripple Peak Phase Distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if numel(ax) > 1 && ishandle(ax(2)), delete(ax(2)); end
ax(2) = axes('Position', [.375 .125 .28 .80]);

bins = -(pi) : pi/8 : (pi + pi/8);

rose(ripPhaseRun.dPhase, bins, 'Parent', ax(2));

% set(ax(4), 'XLim', [-1.05 1.05] * pi , 'XTick', -pi:pi/2:pi);
% set(ax(4), 'XTickLabel', {'-pi','-pi/2',  '0', 'pi/2', 'pi'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       E - Bilateral Ripple Mean Freq Distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if numel(ax) > 2 && ishandle(ax(3)), delete(ax(3)); end

bins = 150:3:225;
occ = hist3([ripFreqRun.base, ripFreqRun.cont], {bins, bins});
% occ = smoothn(occ,1);
ax(3) = axes('Position', [.7 .125 .28 .80]);

imagesc(bins, bins, occ, 'Parent', ax(3));

set(ax(3),'Xlim', [150 225], 'YLim', [150 225], 'YDir', 'normal');

%% Save the figure
save_bilat_figure('figure2', fHandle);
% 
% saveDir = '/data/bilateral/figures';
% figName = ['figure2-', datestr(now, 'yyyymmdd')];
% 
% saveFigure(fHandle, saveDir, figName, 'png', 'fig', 'svg');
% save(fullfile(saveDir, 'figure2-data.mat'))
%%
end