%%
clear;
%animal = 'gh-rsc1';
%day = 'day18';
animal = 'gh-rsc1'; % 'gh-rsc1' or  'sg-rat2'
day = 'day18'; % 'day18' or 'day01'
epType = 'sleep3'; % 'sleep3 or sleep2'
CTX = 'RSC'; % 'RSC' or 'PFC'

% 
% animal = 'sg-rat2';
% day = 'day01';
% epType = 'sleep2';
% CTX = 'PFC';


eegFileName = ['EEG_',CTX,'_250HZ_', upper(epType), '.mat'];

edir = fullfile('/data', animal, day);

if ~exist(fullfile(edir, eegFileName), 'file')
    disp('Loading raw eeg');
    
    e = load_exp_eeg(edir, epType);
    [~, anat] = load_exp_eeg_anatomy(edir);
    chanIdx = strcmp(anat, CTX);
    e.data = e.data(:, chanIdx);
    e.loc = e.loc(chanIdx);
    e.ch = e.ch(chanIdx);
    disp('Downsampling eeg');
    e = downsample_exp_eeg(e, 250);
    
    eegData = e.data;
    eegTs = e.ts;
    eegFs = e.fs;
    clear e;
    disp('Saving eeg');
    save(fullfile(edir, eegFileName), 'eegData', 'eegTs', 'eegFs')
else
    disp('Loading pre-downsampled eeg');
    load(fullfile(edir, eegFileName));
end
clear eegFileName
%%

% - Filter RSC channels in the spindle band (10-20 hz)
eegChan = 1;
eegCtx = eegData(:,eegChan);
s1Filt = getfilter(eegFs, 'spindle', 'win');
% s2Filt = getfilter(fs, 'spindle2', 'win');

disp('Filtering Cortical Lfp for Spindles');
eegSpinBand = filtfilt(s1Filt, 1, eegCtx);
%rscSpin2 = filtfilt(s2Filt, 1, data);

eegSpinEnvelope = abs(hilbert(eegSpinBand));
eegSpinPower = eegSpinBand .^2;

tholdEnvelope = 3 * std(eegSpinEnvelope);
tholdPower = 3 * std(eegSpinPower);


%isSpindlePow = bsxfun(@gt, eegSpinPower, tholdPow);
% isSpindleEnv = bsxfun(@gt, rscEnv, tholdEnv);

% - Load the multi-unit data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   CHANGE THESE VALUES
BURST_LEN = 'SHORT'; % must be SHORT or LONG
TRIG_ON = 'MEAN'; % must be START END MEAN PEAK

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

muFileName = ['MU_SLEEP', epType(end), '.mat'];
muFileName = fullfile(edir, muFileName);

if ~exist('mu', 'var')
    if ~exist(muFileName, 'file')
        disp('Multiunit file not yet created, loading now')
        d = dset_load_all(animal, day, epType);
        mu = d.mu;
        clear d;
        disp('Saving multi-unit file!');
        save(muFileName, 'mu');
    else
        disp('Multiunit file already exists, loading!');
        load(muFileName);
    end
    
    muRate = mu.rate;
    muTs = mu.timestamps;
    muFs = 1/mean(diff(muTs));
    muBursts = mu.bursts;
    clear d;
    
end

%spindleEvents = logical2seg(eegTs, isSpindlePow);
spindleEvents = detect_mountains(eegTs, eegSpinPower, 'threshold', tholdPower);
binarySpindles = eegSpinPower > tholdPower;

isi = [Inf; diff(spindleEvents(:,1))];

%%
% dtThresh = [.25 .15 .15]; % <-- GH Parameteres

dtThresh = [.25 .25 .25];

[multiSpinIdx,singleSpinIdx]  = filter_event_sets(spindleEvents(:,1), 4, dtThresh);


nMulti = nnz(multiSpinIdx);
nSingle = nnz( singleSpinIdx);

fprintf('Multi:%d Single:%d\n', nMulti, nSingle);


multiTimes = spindleEvents(multiSpinIdx,1);
singleTimes = spindleEvents(singleSpinIdx,1);

% [multiSpMean, multiSpAll, ts] = meanTriggeredSignal(multiTimes, eegTs, binarySpindles, [-.5 1]);
% [singleSpMean, singleSpAll, ts] = meanTriggeredSignal(singleTimes, eegTs, binarySpindles, [-.5 1]);

[mMultiSpin, sMultiSpin, ts1] = meanTriggeredSignal(multiTimes, eegTs, eegSpinEnvelope, [-.5 1]);
[mSingleSpin, sSingleSpin] = meanTriggeredSignal(singleTimes, eegTs, eegSpinEnvelope, [-.5 1]);

% mMultiSpin = mean( multiSpinEnv);
% sMultiSpin = std( multiSpinEnv);
% 
% mSingleSpin = mean(singleSpinEnv);
% sSingleSpin = std(singleSpinEnv);

[mMultiMu, sMultiMu, ts2] = meanTriggeredSignal(multiTimes, muTs, muRate * muFs, [-.5 1]);
[mSingleMu, sSingleMu] = meanTriggeredSignal(singleTimes, muTs, muRate * muFs, [-.5 1]);

% mMultiMu = mean( multiMuRate);
% sMultiMu = std( multiMuRate);
% 
% mSingleMu = mean(singleMuRate);
% sSingleMu = std(singleMuRate);
nStd = 1.96;

close all;
figH = figure('Position', [350 700 900 800]);

axH(1) = subplot(211); xlabel('Time (ms)'); ylabel('Envelope');
axH(2) = subplot(212); xlabel('Time (ms)'); ylabel('HPC MU Rate (hz)');

set(axH,'NextPlot', 'add');



%[p(3), l(3)] = error_area_plot(winTime * 1000, mean(muRateRand1), nStd * std(muRateRand1) / sqrt(nRand), 'Parent', axH);
[p(1), l(1)] = error_area_plot(ts1 * 1000, mMultiSpin, nStd * sMultiSpin / sqrt(nMulti), 'Parent', axH(1));
[p(2), l(2)] = error_area_plot(ts1 * 1000, mSingleSpin, nStd * sSingleSpin / sqrt(nSingle), 'Parent', axH(1));


[p(3), l(3)] = error_area_plot(ts2 * 1000, mMultiMu, nStd * sMultiMu / sqrt(nMulti), 'Parent', axH(2));
[p(4), l(4)] = error_area_plot(ts2 * 1000, mSingleMu, nStd * sSingleMu / sqrt(nSingle), 'Parent', axH(2));

title(axH(1), [CTX, ' CTX Spindle Triggered Spindle Band Envelope']);
title(axH(2), [CTX, ' CTX Spindle Triggered HPC MultiUnit']);
legend(axH(1), [l(1), l(2)], 'Triplets', 'Singlets');

set(p,'EdgeColor', 'none');
set(p(1:2:3), 'FaceColor','r'); set(l(1:2:3), 'Color', 'r');
set(p(2:2:4), 'FaceColor','g'); set(l(2:2:4), 'Color', 'g');
set(p,'FaceAlpha', .4);

%% - Save the Figure;
tmpAnimal = animal;
tmpAnimal(tmpAnimal~='-') = '_';
strName = sprintf('%s_%s_mean_%s_SPIN_trig_HPC_MUA', animal,epType, CTX);
saveFigure(figH, '/data/ripple_burst_dynamics/', strName, 'png', 'svg', 'fig');


%%
% 
% 
% [~, multiMuRate, ts] = meanTriggeredSignal(multiTimes, muTs, muRate, [-.5 1]);
% [~, singleMuRate] = meanTriggeredSignal(singleTimes, muTs, muRate, [-.5 1]);
% 
% mMultiMu = mean( multiMuRate);
% sMultiMu = std( multiMuRate);
% 
% mSingleMu = mean(singleMuRate);
% sSingleMu = std(singleMuRate);
% 
% close all;
% figH = figure('Position', [350 500 900 350]);
% axH = axes('NextPlot', 'add');
% nStd = 1.96;
% 
% 
% %[p(3), l(3)] = error_area_plot(winTime * 1000, mean(muRateRand1), nStd * std(muRateRand1) / sqrt(nRand), 'Parent', axH);
% [p(1), l(1)] = error_area_plot(ts * 1000, mMultiMu, nStd * sMultiMu / sqrt(nMulti), 'Parent', axH);
% [p(2), l(2)] = error_area_plot(ts * 1000, mSingleMu, nStd * sSingleMu / sqrt(nSingle), 'Parent', axH);
% 
% set(p,'EdgeColor', 'none');
% set(p(1), 'FaceColor','r'); set(l(1), 'Color', 'r');
% set(p(2), 'FaceColor','g'); set(l(2), 'Color', 'g');
% set(p,'FaceAlpha', .4);


% %%
% 
% 
% 
% mSingleSpin = mean(singleSpinEnv);
% sSingleSpin = std(singleSpinEnv);
% 
% figure; axH = axes;
% nStd = 1.96;
% %[p(3), l(3)] = error_area_plot(winTime * 1000, mean(muRateRand1), nStd * std(muRateRand1) / sqrt(nRand), 'Parent', axH);
% [p(1), l(1)] = error_area_plot(ts * 1000, mMultiSpin, nStd * sMultiSpin / sqrt(nMulti), 'Parent', axH);
% [p(2), l(2)] = error_area_plot(ts * 1000, mSingleSpin, nStd * sSingleSpin / sqrt(nSingle), 'Parent', axH);
% 
% set(p,'EdgeColor', 'none');
% set(p(1), 'FaceColor','r'); set(l(1), 'Color', 'r');
% set(p(2), 'FaceColor','g'); set(l(2), 'Color', 'g');
% set(p,'FaceAlpha', .4);
% 
% 
% %%
% 
% spinDur = diff(spindleEvents, [], 2);
% 
% isi1 = [Inf; diff(spindleEvents(:,1))];
% isi2 = spindleEvents(2:end,1) - spindleEvents(1:end-1,2);
% 
% isi1 = isi(isi1<.5) * 1000;
% isi2 = isi(isi2<.5) * 1000;
% 
% close all;
% [f1, x1] = ksdensity(isi1,1:500);
% [f2, x2] = ksdensity(isi2,1:500);
% 
% axes('NextPlot', 'add');
% plot(x1,f1,'r', 'linewidth', 2);
% plot(x2,f2,'g', 'linewidth', 2);
% legend('isi1', 'isi2');
% 
% 
% 
% 
% close all;
% figure;
% a = axes;
% line_browser(eegTs, eegSpinPower, 'color', 'r', 'Parent', a);
% line_browser(eegTs(tmp), eegSpinPower(tmp), 'color', 'k', 'Parent', a);
% 





