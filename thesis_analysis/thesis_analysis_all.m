clear; close all; clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               LFP ANALYSIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load Data
clear; clc;
ripples = dset_load_ripples;
%% - XCorr the ripple bands
rippleXCorr.run = calc_bilateral_ripple_band_xcorr('run');
rippleXCorr.sleep = calc_bilateral_ripple_band_xcorr('sleep');

%% - Bilateral Ripple Coherence
rippleCoherence.run = calc_bilateral_ripple_coherence(ripples.run, 'raw', 'run');
rippleCoherence.sleep = calc_bilateral_ripple_coherence(ripples.run, 'raw', 'sleep');

save ~/data/thesis/bilateral_ripple_coherence.mat rippleCoherence;

f = plot_bilateral_ripple_coherence(rippleCoherence.run); set(f,'Name','RUN');
f = plot_bilateral_ripple_coherence(rippleCoherence.sleep); set(f,'Name', 'SLEEP');

%% - Bilateral Ripple Frequency Correlations
clearvars -except ripples

rippleFreqCorr.run.spec =  calc_bilateral_ripple_freq_correlations_spec(ripples.run);
rippleFreqCorr.sleep.spec = calc_bilateral_ripple_freq_correlations_spec(ripples.sleep);
rippleFreqCorr.run.mean = calc_bilateral_ripple_freq_correlations_mean(ripples.run);
rippleFreqCorr.sleep.mean = calc_bilateral_ripple_freq_correlations_mean(ripples.sleep);

save ~/data/thesis/bilateral_ripple_frequency_correlation.mat rippleFreqCorr;

f = plot_bilateral_ripple_freq_correlations(rippleFreqCorr.run); set(f,'name', 'RUN');
f = plot_bilateral_ripple_freq_correlations(rippleFreqCorr.sleep); set(f,'name', 'SLEEP');
%% - Mean LFP triggered on ripples



%% - Distribution of Bilateral Ripple Freq Differences




%% - Ripple triggered LFP Averages

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               UNIT AND DECODING ANALYSIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Correlate the number of spikes and the replay score
d = dset_load_all('Bon', 4, 4');
[stats replay] = dset_calc_unilateral_replay_stats(d);
nSpikeReplayScoreCorr = dset_compute_corr_between_nspike_replay_score(dset);



