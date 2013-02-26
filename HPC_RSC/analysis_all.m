clear all;
[MultiUnit, LFP] = load_HPC_RSC_data;

%%
calc_mu_xcorr;
%%
calc_rip_trig_mu;
%%
calc_frame_trig_mu;
%%
calc_frame_trig_frame;
%%
calc_frame_d_start_dist;
%%
calc_frame_trig_mu_rate_corr;