%% eeg_analysis

e = exp;
epochs = {'midazolam', 'control'};
states = {'run', 'rip'};

enum=2;
e_data = [];
h = spectrum.mtm;


for a = epochs
    ep = a{1};
    for b = states;
        st = b{1};
        if strcmp(st, 'rip')
        disp('Not implemented');
        else
            [e_data.(ep).(st).eeg e_data.(ep).(st).timestamps] = exp.(ep).eeg(enum).load_window();
            ind = floor(1/2 * length(e_data.(ep).(st).eeg));
            
            x = e_data.(ep).(st).eeg(1:ind);
       %     [e_data.(ep).(st).spectrum(1,:) e_data.(ep).(st).freq(1,:)] =...
        %        pmtm(x, 4, [.5:.5:200], 500);
            
            x = e_data.(ep).(st).eeg(ind:end);
         %   [e_data.(ep).(st).spectrum(2,:) e_data.(ep).(st).freq(2,:)] =...
          %      pmtm(x, 4, [.5:.5:200], 500);
        end    
    end
end
%%

figure; plot(mean(e_data.control.run.freq,1), log(mean(e_data.control.run.spectrum)));
title('control');
figure; plot(mean(e_data.midazolam.run.freq,1), log(mean(e_data.midazolam.run.spectrum)));
title('midazolam');



%% Calculate Spectrogram

[spec.con, f.con, t.con] = my_spectrogram(e_data.control.run.eeg, 2000, 4, .8, 500);
[spec.mid, f.mid, t.mid] = my_spectrogram(e_data.midazolam.run.eeg, 2000, 4, .8, 500);

%% Smooth Spectrogram
spec.smooth.con{1} = smoothn(spec.con,1);
spec.smooth.con{2} = smoothn(spec.con,2);

spec.smooth.mid{1} = smoothn(spec.mid,1);
spec.smooth.mid{2} = smoothn(spec.mid,2);

%% Plot Spectrogram
tmax = max(t.con);
ind = find(t.mid<=tmax);

figure; 
subplot(411); plot_spectrogram(spec.smooth.con{1}, f.con, t.con, .1, 30);
title('Control');
subplot(412); plot_spectrogram(spec.smooth.mid{2}(:,ind), f.mid, t.mid(ind), .1, 30);
title('Midazolam');
subplot(413); plot_spectrogram(spec.smooth.con{1}, f.con, t.con, 100, 200);
title('Control');
subplot(414); plot_spectrogram(spec.smooth.mid{2}(:,ind), f.mid, t.mid(ind), 100, 200);
title('Midazolam');

%% Spectrum of Ripple Events:

h = spectrum.mtm;

for e = epochs;
    ep = e{1};    
    d = diff(exp.(ep).mub_times');
    c = 0;
    for i=1:length(exp.(ep).mub_times)
        if (d(i) > .125 && d(i)<.600)
            c = c+1;
            t = exp.(ep).mub_times(i,:);
            ind = e_data.(ep).run.timestamps>=t(1) & e_data.(ep).run.timestamps<=t(2);
            [spec_n.(ep).spec(:,c) spec_n.(ep).f] = pmtm(e_data.(ep).run.eeg(ind), 2, [1:1:250], 500);
        end
    end
end
%%
    
bs_mid = bootstrp(1000, @mean, spec_n.midazolam.spec');
bs_con = bootstrp(1000, @mean, spec_n.control.spec');

%%
std_mid = std(bs_mid);
std_con = std(bs_con);
figure;
plot(log(mean(bs_mid)),'k','LineWidth', 2); hold on;

plot(log(mean(bs_con)),'r', 'LineWidth', 2);

plot(log(mean(bs_mid)+2.*std_mid), 'k--');
plot(log(mean(bs_mid)-2.*std_mid), 'k--');


plot(log(mean(bs_con)+2.*std_con), 'r--');
plot(log(mean(bs_con)-2.*std_con), 'r--');

legend('Midazolam', 'Control');
title('Spectral Content of Ripple Events');
ylabel('dB'); xlabel('Frequency');

%%
f_ind = spec_n.midazolam.f>50;
figure;
subplot(211);
imagesc(1:length(spec_n.midazolam.spec), spec_n.midazolam.f(f_ind), log(spec_n.midazolam.spec(f_ind,:))); set(gca, 'YDir', 'normal'); title('Midazolam');
subplot(212);
imagesc(1:length(spec_n.control.spec), spec_n.control.f(f_ind), log(spec_n.control.spec(f_ind,:))); set(gca, 'YDir', 'normal'); title('Control');
linkaxes







