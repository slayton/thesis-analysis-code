% clear;
% eList = dset_list_epochs('run');
% 
% for i = 1:size(eList,1)
%     d = dset_load_all(eList{i,1},eList{i,2}, eList{i,3});
%     d = dset_add_ref_to_eeg(d);
% 
% 
%     
%     [d w t] = dset_get_ripple_events(d);
%     
%     run(i).dataset = sprintf('%s %d - %d', eList{i,1}, eList{i,2}, eList{i,3});
%     run(i).rips{d.channels.base} = d.eeg(d.channels.base).rips;
%     run(i).rips{d.channels.ipsi} = d.eeg(d.channels.ipsi).rips;
%     run(i).rips{d.channels.cont} = d.eeg(d.channels.cont).rips;
%     
%     run(i).raw{d.channels.base} = d.eeg(d.channels.base).data(w);
%     run(i).raw{d.channels.ipsi} = d.eeg(d.channels.ipsi).data(w);
%     run(i).raw{d.channels.cont} = d.eeg(d.channels.cont).data(w);
%     
%     run(i).peakTs = t;
%     run(i).window = w;
%     run(i).fs = d.eeg(1).fs;
%     
% end
% save('/data/franklab/bilateral/ALL_RIPS_NO_REF_RUN.mat', 'run' );
% 
% 
% %%
clear;
eList = dset_list_epochs('sleep');
for i = 1:size(eList,1)
    d = dset_load_all(eList{i,1},eList{i,2}, eList{i,3});
    d = dset_add_ref_to_eeg(d);
    
    [d w t] = dset_get_ripple_events(d);
    
    sleep(i).dataset = sprintf('%s %d - %d', eList{i,1}, eList{i,2}, eList{i,3});

    sleep(i).dataset = sprintf('%s %d - %d', eList{i,1}, eList{i,2}, eList{i,3});
    sleep(i).rips{d.channels.base} = d.eeg(d.channels.base).rips;
    sleep(i).rips{d.channels.ipsi} = d.eeg(d.channels.ipsi).rips;
    sleep(i).rips{d.channels.cont} = d.eeg(d.channels.cont).rips;
    
    sleep(i).raw{d.channels.base} = d.eeg(d.channels.base).data(w);
    sleep(i).raw{d.channels.ipsi} = d.eeg(d.channels.ipsi).data(w);
    sleep(i).raw{d.channels.cont} = d.eeg(d.channels.cont).data(w);    
    
    sleep(i).peakTs = t;
    sleep(i).window = w;
    sleep(i).fs = d.eeg(1).fs;
end
save('/data/franklab/bilateral/ALL_RIPS_NO_REF_SLEEP.mat', 'sleep');

% 
% %%
% 
% clear;
% eList = dset_list_epochs('run');
% 
% for i = 1:size(eList,1)
%     d = dset_load_all(eList{i,1},eList{i,2}, eList{i,3});
%     
%     [d w t] = dset_get_ripple_events(d);
%     
%     run(i).dataset = sprintf('%s %d - %d', eList{i,1}, eList{i,2}, eList{i,3});
%     run(i).rips{d.channels.base} = d.eeg(d.channels.base).rips;
%     run(i).rips{d.channels.ipsi} = d.eeg(d.channels.ipsi).rips;
%     run(i).rips{d.channels.cont} = d.eeg(d.channels.cont).rips;
%     
%     run(i).raw{d.channels.base} = d.eeg(d.channels.base).data(w);
%     run(i).raw{d.channels.ipsi} = d.eeg(d.channels.ipsi).data(w);
%     run(i).raw{d.channels.cont} = d.eeg(d.channels.cont).data(w);
%     
%     run(i).peakTs = t;
%     run(i).window = w;
%     run(i).fs = d.eeg(1).fs;
%     
% end
% save('/data/franklab/bilateral/ALL_RIPS_RUN.mat', 'run' );
% %%
% 
% clear
% eList = dset_list_epochs('sleep');
% for i = 1:size(eList,1)
%     d = dset_load_all(eList{i,1},eList{i,2}, eList{i,3});
%     [d w t] = dset_get_ripple_events(d);
%     
%     sleep(i).dataset = sprintf('%s %d - %d', eList{i,1}, eList{i,2}, eList{i,3});
% 
%     sleep(i).dataset = sprintf('%s %d - %d', eList{i,1}, eList{i,2}, eList{i,3});
%     sleep(i).rips{d.channels.base} = d.eeg(d.channels.base).rips;
%     sleep(i).rips{d.channels.ipsi} = d.eeg(d.channels.ipsi).rips;
%     sleep(i).rips{d.channels.cont} = d.eeg(d.channels.cont).rips;
%     
%     sleep(i).raw{d.channels.base} = d.eeg(d.channels.base).data(w);
%     sleep(i).raw{d.channels.ipsi} = d.eeg(d.channels.ipsi).data(w);
%     sleep(i).raw{d.channels.cont} = d.eeg(d.channels.cont).data(w);    
%     
%     sleep(i).peakTs = t;
%     sleep(i).window = w;
%     sleep(i).fs = d.eeg(1).fs;
% end
% save('/data/franklab/bilateral/ALL_RIPS_SLEEP.mat', 'sleep');
