function generateFigure3_2B
open_pool;
%% Ripple Triggered Average Multi-unit Activity

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Load Sleep Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
% %%%%% SLEEP %%%%%
% sleepEpochs = dset_list_epochs('sleep');
% % runEpochs = dset_list_epochs('run');
% ripples = dset_load_ripples;
% ripples = ripples.sleep(2);
% 
% dset = dset_load_all(sleepEpochs{2,1}, sleepEpochs{2,2}, sleepEpochs{2,3});    
% % dsetR = dset_load_all(runEpochs{1,1}, runEpochs{1,2}, runEpochs{1,3});    
% %%
% Fs = dset.eeg(1).fs;
% nSamp = round( .25 * Fs );
% win = [-nSamp:nSamp];
% 
% ts = dset_calc_timestamps(dset.eeg(1).starttime, numel(dset.eeg(1).data), dset.eeg(1).fs);
% muRate = interp1(dset.mu.timestamps, dset.mu.rate, ts);
% muRate(isnan(muRate))=0;
% 
% ripWin = bsxfun(@plus, win, ripples.peakIdx);
% mua = muRate(ripWin);
% meanMuaSleep = mean(mua);
looking_for_beta_load_data;
%% XCORR EEG and MUA
% ts = dset_calc_timestamps(dset.eeg(1).starttime, numel(dset.eeg(1).data), dset.eeg(1).fs);
% muRate = interp1(dset.mu.timestamps, dset.mu.rate, ts);
% muRate(isnan(muRate))=0;
% events = dset.mu.bursts;
% burstIdx = arrayfun(@(x,y) ( ts >= x & ts <= y ), events(:,1), events(:,2), 'UniformOutput', 0 );
% burstIdx = sum(cell2mat(burstIdx));
% 
% eeg = dset.eeg(1).data .* burstIdx';
% mu = muRate' .* burstIdx';
% 
% xcWin = .25;
% [xc lags] = xcorr(eeg, eeg, ceil( xcWin * dset.eeg(1).fs), 'unbiased' );
% lags = lags / dset.eeg(1).fs;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Plot The Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = figure;
a = axes;

line(1000 * win/ Fs, meanMuaRun, 'color', [1 0 0], 'linewidth', 2);
line(1000 * win / Fs, meanMuaSleep, 'Color', [0 0 1], 'linewidth', 2);

line([0 0], get(gca,'Ylim'));
set(gca,'XLim', [-250 250]);
line([0 0], get(gca,'Ylim'), 'Color', 'k');
set(gca,'YTick', []);
xlabel('Time (ms)');
ylabel('Multiunit Rate');

title('RipTrig Average MUA');

%%
save_bilat_figure('figure3-2B', f);


end


