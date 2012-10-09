%% eeg_analysis
exp = citrus;
n_chans = length(exp.midazolam.eeg);

epochs = {'saline', 'midazolam'}
data = [];

rhil = calculate_ave_hilbert(exp);
for ep = epochs   
    e = ep{1};
    exp.(e).r_hil_ave = smoothn(rhil.(e), .0125, exp.(e).eeg(1).fs);
end
times = find_ripple_times(exp);
for ep = epochs
    e = ep{1};
    exp.(e).ripple_times = times.(e);
end


%% Spectrum of Ripple Events, using RIPPLE TIMES or MUB NEW
clear spec_n ep ind test fr sp peak_f; 
n_events = 100;
chan = 4;

%trigger = 'MUB';
trigger = 'ripple';
filter = 0; % 0: no filter, 1: 0-40 hz, 2: 40-100 hz, 3: ripple band
n_points = 125;
win_len = (n_points*2)/exp.midazolam.eeg(1).fs;

for ep = epochs;
    e = ep{1};    
    c = 0;
    fs = exp.(e).eeg(1).fs;
    
    
    test.(e) = [];
    spec_n.(e).spec = nan(2049, n_events);
    peak_f.(e) = nan(n_events,1);
    switch strcmp(trigger, 'mub_times')
        case 1
            events = randsample(mean(exp.(e).multiunit.burst_times,2), n_events );
        case 0
            events = randsample(mean(exp.(e).rip_burst.windows,2), n_events );
    end
    switch filter
        case 0
            sig = exp.(e).eeg(chan).data;
        case 1
            f = getfilter(exp.(e).eeg(1).fs, 'ripple', 'win');
        case 2
        case 3
            f = getfilter(exp.(e).eeg(1).fs, 'ripple', 'win');
            ig = filtfilt(f,1,exp.(e).eeg(chan).data);
    end

    for i=1:length(events)
        ind = find(exp.(e).eeg_ts>events(i),1,'first');
        ind = ind-125:ind+125;
        if min(ind)>0 && max(ind)<length(exp.(e).eeg_ts) 
            c = c+1;

            [sp fr] = pmtm(double(sig(ind)), 1.5, 2^12, fs);

            spec_n.(e).spec(:,c)  = sp;

            spec_n.(e).f = fr;
            
            ind = fr>100 & fr<250;
            peak_f.(e)(c) = fr( sp==max(sp(ind)) );
            
            test.(e) = [test.(e), exp.(e).eeg(chan).data(ind)];
        end
        disp([e, '-',num2str(i)]);
    end
end

%%

bs_mid = bootstrp(1000, @mean, spec_n.midazolam.spec');
bs_con = bootstrp(1000, @mean, spec_n.saline.spec');

%% -- Plot the average boot strapped spectrum with confidence bounds
std_mid = std(bs_mid);
std_con = std(bs_con);
figure;
plot(spec_n.saline.f, log(mean(bs_mid)),'k','LineWidth', 2); hold on;

plot(spec_n.saline.f,log(mean(bs_con)),'r', 'LineWidth', 2);

plot(spec_n.saline.f,log(mean(bs_mid)+2.*std_mid), 'k--');
plot(spec_n.saline.f,log(mean(bs_mid)-2.*std_mid), 'k--');


plot(spec_n.saline.f,log(mean(bs_con)+2.*std_con), 'r--');
plot(spec_n.saline.f,log(mean(bs_con)-2.*std_con), 'r--');

legend('Midazolam', 'Control');
title(['Mean Ripple Spectrum, triggered on ', trigger ,', ',num2str(floor(win_len*1000)), ' ms wide']);
ylabel('dB'); xlabel('Frequency');

%% -- Plot the spectrograms
f_ind = spec_n.midazolam.f>50;
figure('Position', [235 515 1000 500]);

spec_big = [spec_n.midazolam.spec, spec_n.saline.spec];
spec_big = smoothn(spec_big,1);
imagesc(1:length(spec_n.midazolam.spec)*2, spec_n.midazolam.f, log(spec_big)); 

line(repmat(length(spec_n.midazolam.spec), 2, 1), [max(spec_n.midazolam.f),0], 'Color', 'k');
set(gca, 'YDir', 'normal', 'XTick', []); 
title(['Ripple Spectrum, triggered on ', trigger ,', ',num2str(floor(win_len*1000)), ' ms wide']);
ylabel('Frequency');
uicontrol('Style', 'text', 'String', 'Midazolam', 'Units', 'Normalized',...
    'Position', [.25, .065 .1 .03], 'backgroundColor', [.8 .8 .8]);
uicontrol('Style', 'text', 'String', 'Control', 'Units', 'Normalized',...
    'Position', [.65, .065 .1 .03], 'backgroundColor', [.8 .8 .8]);


%% -- Compare the Peak Ripple frequency distribution
clear hist_con hist_mid f_bins;
figure;
f_bins = 100:5:250;

hist_mid = histc(peak_f.midazolam, f_bins);
hist_con = histc(peak_f.saline, f_bins);
hist_mid = smoothn(hist_mid,3);
hist_con = smoothn(hist_con,3);

h_mid_se = std(bootstrp(1000, @(x) histc( x, f_bins ), peak_f.midazolam));
h_mid_se = smoothn(h_mid_se,3)';
h_con_se = std(bootstrp(1000, @(x) histc( x, f_bins ), peak_f.saline));
h_con_se = smoothn(h_con_se,3)';

plot(f_bins, hist_mid, 'k', 'linewidth',2); hold on;
plot(f_bins, hist_con, 'r', 'linewidth',2);

plot(f_bins, hist_mid+2*h_mid_se, '--k',...
     f_bins, hist_mid-2*h_mid_se, '--k')


plot(f_bins, hist_con+2*h_con_se, '--r',...
     f_bins, hist_con-2*h_con_se, '--r'); hold off;

title('Distribution of Peak Ripple Frequency');
legend('Midazolam', 'Control');
xlabel('Frequency');

%%





















