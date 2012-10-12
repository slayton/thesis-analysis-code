clc; clear all; closea all;
epochsToAnalyze = {'sleep', 'run'};

for eNumber = 1:numel(epochsToAnalyze)
    
    epoch = epochsToAnalyze{eNumber};
    epochList = dset_list_epochs(epoch);
    

    for i = 1:size(epochList,1);
        d = dset_load_all(epochList{i,1},epochList{i,2}, epochList{i,3});
        rp = dset_compute_ripple_params(d);
        
        data.(epoch)(i) = rp;
        
%         [d, w, t] = dset_get_ripple_events(d);
%         d = dset_calc_ripple_spectrum(d);
%         
%         data.(epoch)(i).description = dset_get_description_string(d);
%         
%         data.(epoch)(i).rips = d.ripples.rips;
%         data.(epoch)(i).spect = d.ripples.spect;
%         data.(epoch)(i).spectW = d.ripples.spectW;
%         data.(epoch)(i).f = d.ripples.f;
%         data.(epoch)(i).peakTs = d.ripples.peakTs;
%         data.(epoch)(i).peakFr = d.ripples.peakFreq;
%         data.(epoch)(i).window = w;
%         data.(epoch)(i).fs = d.eeg(1).fs;
%         for j = 1:3
%             data.(epoch)(i).raw{j} = d.eeg(j).data(w);
%         end

    end
end

saveFile = '/data/franklab/bilateral/all_ripples.mat';
fprintf('Saving file: %s\n', saveFile);
save(saveFile, 'data');

%%
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
% clear;
% epochList = dset_list_epochs('sleep');
% for i = 1:size(epochList,1)
%     d = dset_load_all(epochList{i,1},epochList{i,2}, epochList{i,3});
%     d = dset_add_ref_to_eeg(d);
%     
%     [d w t] = dset_get_ripple_events(d);
%     
%     sleep(i).dataset = sprintf('%s %d - %d', epochList{i,1}, epochList{i,2}, epochList{i,3});
%     
%     sleep(i).dataset = sprintf('%s %d - %d', epochList{i,1}, epochList{i,2}, epochList{i,3});
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
