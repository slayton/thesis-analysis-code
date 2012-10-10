clear; close all; clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               LFP ANALYSIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% - Bilateral Ripple Coherence
rippleCoherence.run = calc_bilateral_ripple_coherence('raw', 0, 'run');
rippleCoherence.sleep = calc_bilateral_ripple_coherence('raw', 0, 'sleep');

save ~/data/thesis/bilateral_ripple_coherence.mat rippleCoherence;

plot_bilateral_ripple_coherence(rippleCoherence.run);
plot_bilateral_ripple_coherence(rippleCoherence.sleep);


%% - Bilateral Ripple Frequency Correlations

%% - Distribution of Bilateral DELTA Ripple Freq

%% - Ripple triggered LFP Averages