%% compare MUB duration distributions

bins = 0:.01:1;

h_mid = histc(diff(gh.midazolam.multiunit.burst_times,1,2), bins);
h_con = histc(diff(gh.control.multiunit.burst_times,1,2), bins);

h_mid_s = smoothn(h_mid, 4);
h_con_s = smoothn(h_con, 4);
plot(bins, h_mid_s, 'k', bins, h_con_s, 'r', 'LineWidth', 2);
title('MUB Distribution');
xlabel('Duration in seconds');
legend('Midazolam', 'Control');

%% compare MUB occurance distribution

b_mid = gh.midazolam.multiunit.burst_times(:,1);
b_con = gh.control.multiunit.burst_times(:,1);


dt = 5;

bins_m = b_mid(1):dt:b_mid(end);
h_mid = histc(b_mid, bins_m);

bins_c = b_con(1):dt:b_con(end);
h_con = histc(b_con, bins_c);

ind = 1:numel(bins_c);
subplot(211);
plot(bins_m(ind), h_mid(ind)/dt);
subplot(212);
plot(bins_c, h_con/dt);

%% inter-ripple intervals
