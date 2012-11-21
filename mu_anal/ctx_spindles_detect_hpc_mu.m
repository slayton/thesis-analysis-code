% Looking to see if there is a correlation between spindles in RSC and
% beta?! modulated multi-unit bursts in the HPC


%%
clear;
animal = 'gh-rsc1';
day = 'day18';
edir = fullfile('/data', animal, day);
eegFileName = 'EEG_RSC_250HZ_SLEEP3.mat';
epType = 'sleep3';

if ~exist(fullfile(edir, eegFileName), 'file')
    disp('Loading raw eeg');
   
    e = load_exp_eeg(edir, epType);
    [~, anat] = load_exp_eeg_anatomy(edir);
    chanIdx = strcmp(anat, 'RSC');
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


% - Filter RSC channels in the spindle band (10-20 hz)
rscChan = 1;
rscEeg = eegData(:,rscChan);
s1Filt = getfilter(eegFs, 'spindle1', 'win');
% s2Filt = getfilter(fs, 'spindle2', 'win');

disp('Filtering RSC EEG for Spindles');
rscSpinBand = filtfilt(s1Filt, 1, rscEeg);
%rscSpin2 = filtfilt(s2Filt, 1, data);

rscEnv = abs(hilbert(rscSpinBand));
rscPow = rscSpinBand .^2;

tholdEnv = 3 * std(rscEnv);
tholdPow = 3 * std(rscPow);

isSpindleEnv = bsxfun(@gt, rscPow, tholdPow);

% - Load the multi-unit data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   CHANGE THESE VALUES            
BURST_LEN = 'SHORT'; % must be SHORT or LONG
TRIG_ON = 'MEAN'; % must be START END MEAN PEAK

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

muFileName = 'MU_SLEEP3.mat';
muFileName = fullfile(edir, muFileName);

if ~exist('mu', 'var')
    if ~exist(muFileName, 'file')
        disp('Multiunit file not yet created, loading now')
        d = dset_load_all('gh-rsc1', 'day18', epType);
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
    muFs = mean(diff(muTs));
    muBursts = mu.bursts;
    clear d;
    
end
%%
spindles = logical2seg(eegTs, isSpindleEnv);
isi = [nan; diff(spindles(:,1))];
dtThresh = [1 .25];
setIdx.trip = [];
setIdx.sing = [];

tmpSetIdx3 = nan(size(isi));
tmpSetIdx1 = nan(size(isi));

for j = 1:numel(isi)-4
    if isi(j) > dtThresh(1)
        if isi(j+1) < dtThresh(2)
            if isi(j+2) < dtThresh(2)
                    tmpSetIdx3(j) = j;

            end
        else
            tmpSetIdx1(j) = j;
        end
    end
end
tripSpindleIdx = tmpSetIdx3( isfinite(tmpSetIdx3));
soloSpindleIdx = tmpSetIdx1( isfinite(tmpSetIdx1));

fprintf('N Trip:%d N Solo:%d\n', numel(tripSpindleIdx), numel(soloSpindleIdx));

% convert the spindle event ts from eeg ts to mu ts
eegTripSpindleTs = spindles(tripSpindleIdx,1);
eegSoloSpindleTs = spindles(soloSpindleIdx,1);

muTripSpindTs = interp1(muTs, muTs, eegTripSpindleTs,'nearest');
muSoloSpindTs = interp1(muTs, muTs, eegSoloSpindleTs,'nearest');

muTripSpindIdx = interp1(muTs, 1:numel(muTs), muTripSpindTs);
muSoloSpindIdx = interp1(muTs, 1:numel(muTs), muSoloSpindTs);


winLen = .5;
winLenSamp = winLen /muFs;
winSamps = [-winLenSamp:winLenSamp];
winTime = muFs *  winSamps;

winSampsTrip = bsxfun(@plus,  winSamps, muTripSpindIdx);
winSampsSolo = bsxfun(@plus,  winSamps, muSoloSpindIdx);


muRateTrip = muRate(winSampsTrip);
muRateSolo = muRate(winSampsSolo);


close all; figH = figure;
axH = axes;

plot(winTime, mean(muRateTrip), 'r'); hold on;
plot(winTime, mean(muRateSolo), 'b');
legend({'Trip', 'Solo'}, 'Location', 'northwest');



%% - Save the Figure;
tmpAnimal = animal;
tmpAnimal(tmpAnimal~='-') = '_';
strName = sprintf('%s_%s_mean_SPIN_trig_%s_%s', animal,epType, BURST_LEN, TRIG_ON );
saveFigure(figH, '/data/ripple_burst_dynamics/', strName, 'png', 'svg', 'fig');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% Looking to see if there is a correlation between spindles in RSC and
% beta?! modulated multi-unit bursts in the HPC


%%
clear;
animal = 'gh-rsc1';
day = 'day18';
edir = fullfile('/data', animal, day);
eegFileName = 'EEG_RSC_250HZ_SLEEP3.mat';
epType = 'sleep3';

if ~exist(fullfile(edir, eegFileName), 'file')
    disp('Loading raw eeg');
   
    e = load_exp_eeg(edir, epType);
    [~, anat] = load_exp_eeg_anatomy(edir);
    chanIdx = strcmp(anat, 'RSC');
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


% - Filter RSC channels in the spindle band (10-20 hz)
rscChan = 1;
rscEeg = eegData(:,rscChan);
s1Filt = getfilter(eegFs, 'spindle1', 'win');
% s2Filt = getfilter(fs, 'spindle2', 'win');

disp('Filtering RSC EEG for Spindles');
rscSpinBand = filtfilt(s1Filt, 1, rscEeg);
%rscSpin2 = filtfilt(s2Filt, 1, data);

rscEnv = abs(hilbert(rscSpinBand));
rscPow = rscSpinBand .^2;

tholdEnv = 3 * std(rscEnv);
tholdPow = 3 * std(rscPow);

isSpindlePow = bsxfun(@gt, rscEnv, tholdEnv);
isSpindleEnv = bsxfun(@gt, rscPow, tholdPow);

spindles = logical2seg(eegTs, isSpindleEnv);

% - Load the multi-unit data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   CHANGE THESE VALUES            
BURST_LEN = 'SHORT'; % must be SHORT or LONG
TRIG_ON = 'MEAN'; % must be START END MEAN PEAK

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

muFileName = 'MU_SLEEP3.mat';
muFileName = fullfile(edir, muFileName);

if ~exist('mu', 'var')
    if ~exist(muFileName, 'file')
        disp('Multiunit file not yet created, loading now')
        d = dset_load_all('gh-rsc1', 'day18', epType);
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
    muFs = mean(diff(muTs));
    muBursts = mu.bursts;
    clear d;
    
end
%%
% Compute stats using Spindle burst length instead of spindle bursts
% convert spindles from events to bursts, and then filter on event length

spindles = logical2seg(eegTs, isSpindlePow);
idx = false(size(spindles(:,1)));
prevSpinTime = 0;
dt = .5
for i = 1:numel(idx)
    
    
    
end
%%
isi = [nan; diff(spindles(:,1))];
dtThresh = [1 1];
setIdx.trip = [];
setIdx.sing = [];

tmpSetIdx3 = nan(size(isi));
tmpSetIdx1 = nan(size(isi));

for j = 1:numel(isi)-3
    if isi(j) > dtThresh(1)
        if isi(j+1) < dtThresh(2)
            if isi(j+2) < dtThresh(2)
                tmpSetIdx3(j) = j;
            end
        else
            tmpSetIdx1(j) = j;
        end
    end
end
tripSpindleIdx = tmpSetIdx3( isfinite(tmpSetIdx3));
soloSpindleIdx = tmpSetIdx1( isfinite(tmpSetIdx1));

fprintf('N Trip:%d N Solo:%d\n', numel(tripSpindleIdx), numel(soloSpindleIdx));

% convert the spindle event ts from eeg ts to mu ts
eegTripSpindleTs = spindles(tripSpindleIdx,1);
eegSoloSpindleTs = spindles(soloSpindleIdx,1);

muTripSpindTs = interp1(muTs, muTs, eegTripSpindleTs,'nearest');
muSoloSpindTs = interp1(muTs, muTs, eegSoloSpindleTs,'nearest');

muTripSpindIdx = interp1(muTs, 1:numel(muTs), muTripSpindTs);
muSoloSpindIdx = interp1(muTs, 1:numel(muTs), muSoloSpindTs);


winLen = .5;
winLenSamp = winLen /muFs;
winSamps = [-winLenSamp:winLenSamp];
winTime = muFs *  winSamps;

winSampsTrip = bsxfun(@plus,  winSamps, muTripSpindIdx);
winSampsSolo = bsxfun(@plus,  winSamps, muSoloSpindIdx);


muRateTrip = muRate(winSampsTrip);
muRateSolo = muRate(winSampsSolo);


close all; figH = figure;
axH = axes;

plot(winTime, mean(muRateTrip), 'r'); hold on;
plot(winTime, mean(muRateSolo), 'b');
legend({'Trip', 'Solo'}, 'Location', 'northwest');



%% - Save the Figure;
tmpAnimal = animal;
tmpAnimal(tmpAnimal~='-') = '_';
strName = sprintf('%s_%s_mean_SPIN_trig_%s_%s', animal,epType, BURST_LEN, TRIG_ON );
saveFigure(figH, '/data/ripple_burst_dynamics/', strName, 'png', 'svg', 'fig');







