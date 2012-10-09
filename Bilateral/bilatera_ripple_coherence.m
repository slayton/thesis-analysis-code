clear;
%%
eList = dset_list_epochs('run');

for i = 1:size(eList,1)
    d = dset_load_all(eList{i,1},eList{i,2}, eList{i,3});
    [d w] = dset_get_ripple_events(d);
    
    run(i).dataset = sprintf('%s %d - %d', eList{i,1}, eList{i,2}, eList{i,3});
    run(i).rips{d.channels.base} = d.eeg(d.channels.base).rips;
    run(i).rips{d.channels.ipsi} = d.eeg(d.channels.ipsi).rips;
    run(i).rips{d.channels.cont} = d.eeg(d.channels.cont).rips;
    
    run(i).raw{d.channels.base} = d.eeg(d.channels.base).data(w);
    run(i).raw{d.channels.ipsi} = d.eeg(d.channels.ipsi).data(w);
    run(i).raw{d.channels.cont} = d.eeg(d.channels.cont).data(w);
    run(i).window = w;
end

save('/data/franklab/bilateral/ALL_RIPS_RUN.mat', 'run');


clear;

eList = dset_list_epochs('sleep');

for i = 1:size(eList,1)
    d = dset_load_all(eList{i,1},eList{i,2}, eList{i,3});
    [d w] = dset_get_ripple_events(d);
    
     sleep(i).dataset = sprintf('%s %d - %d', eList{i,1}, eList{i,2}, eList{i,3});

    rips(i).dataset = sprintf('%s %d - %d', eList{i,1}, eList{i,2}, eList{i,3});
    rips(i).rips{d.channels.base} = d.eeg(d.channels.base).rips;
    rips(i).rips{d.channels.ipsi} = d.eeg(d.channels.ipsi).rips;
    rips(i).rips{d.channels.cont} = d.eeg(d.channels.cont).rips;
    
    rips(i).raw{d.channels.base} = d.eeg(d.channels.base).data(w);
    rips(i).raw{d.channels.ipsi} = d.eeg(d.channels.ipsi).data(w);
    rips(i).raw{d.channels.cont} = d.eeg(d.channels.cont).data(w);
    rips(i).window = w;
end

save('/data/franklab/bilateral/ALL_RIPS_SLEEP2.mat', 'rips', 'eList');

%%


%%
c = [];
for j = 1:N
    fprintf('\n\n --%d-- \n', j);
    d = dset_load_all(eList{j,1},eList{j,2}, eList{j,3});
    [d w] = dset_get_ripple_events(d);

%    r1 = d.eeg(d.channels.base).data(w);
%    r2 = d.eeg(d.channels.cont).data(w);
    r1 = d.eeg(d.channels.base).rips;
    r2 = d.eeg(d.channels.ipsi).rips;

    nRip = size(r1,1);

    nfft = 256;
    noverlap = 128;
    
    for i = 1:nRip
        [c(end+1,:) F] = mscohere(r1(i,:),r2(i,:),[], noverlap, nfft, d.eeg(1).fs);

    end
end
%%
semCohere = std(c) / sqrt(nRip);
mCohere = mean(c);

error_area_plot(F, mCohere, semCohere, 'r', 'k');
set(gca, 'XLim', [0 400])


