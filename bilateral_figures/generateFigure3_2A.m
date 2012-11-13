function generateFigure3_2A
open_pool;
%% SHOW THE RAW RIPPLES AND MUA

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Prepare the data for plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
%%%%% SLEEP %%%%%
dSleep = dset_load_all('spl11', 'day14', 'sleep2');
eeg = dSleep.eeg; 
clear dSleep;

mu = load_exp_mu('/data/spl11/day14', 'sleep2');

ts = dset_calc_timestamps(eeg(1).starttime, numel(eeg(1).data), eeg(1).fs);

muRate = histc(mu, ts) / mean(diff(ts));

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Plot The Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('fig3_2A', 'var'), if ishandle(fig3_2A), delete(fig3_2A); end; end;

fig3_2A = figure('Position', [650 50  700 200]);
ax3_2A = axes('Position', [.13 .3 .775 .63]);

xlim = [5850.3 5850.85];
plotIdx = ts >= xlim(1) & ts <= xlim(2);
muRateSm = smoothn(muRate, 6);

b = bar(ts(plotIdx), muRateSm(plotIdx), 1,'c'); 
l = line(ts(plotIdx), 3*eeg(1).data(plotIdx) + 10000, 'Color', 'w');

set(ax3_2A, 'Xlim', xlim, 'YLim', [0 13500], 'Color', 'k', 'YTick', []);
xlabel('Time (s)');


%%
save_bilat_figure('figure3-2A', fig3_2A);


end

