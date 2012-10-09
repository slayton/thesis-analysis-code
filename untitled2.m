

d = dset_load_all('Bon', 4, 4);
[d w] = dset_get_ripple_events(d);

%%
idx = 151:451;%101:501;
Hs = spectrum.mtm(2);
figure;

for i = 1:3
    
meanRaw = mean(d.eeg(i).data(w));
meanRip = mean(d.eeg(i).rips);
    
specRaw = psd(Hs, meanRaw(idx), 'Fs', d.eeg(i).fs);
specRip = psd(Hs, meanRip(idx), 'Fs', d.eeg(i).fs);

plot(specRaw.Frequencies, log(specRaw.Data)); hold on;
plot(specRip.Frequencies, log(specRip.Data), 'r'); hold off;

set(gca,'Xlim', [0 250]);
pause;
end
%%

r1 = d.eeg(1).data(w);
r2 = d.eeg(2).data(w);

nRip = size(r1,1);

nfft = 256;
noverlap = 128;

c = [];

for i = 1:nRip
    [c(i,:) F] = mscohere(r1(i,:),r2(i,:),[], noverlap, nfft, d.eeg(1).fs);
    
end

semCohere = std(c) / sqrt(nRip);
mCohere = mean(c);


f = figure;
ax = axes;

fill( [F', fliplr(F')], [mCohere + semCohere, fliplr( mCohere - semCohere) ], 'r')
