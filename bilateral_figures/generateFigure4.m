function generateFigure4
%% Load all the data required for plotting!
open_pool;
%%
clear;
runReconFiles = dset_get_recon_file_list('run');
unilatReplayStatsCorr = calc_unilateral_replay_bilateral_correlations(d, recon.replay, recon.stats);


%% Plot the figure


%% Save the Figure


end