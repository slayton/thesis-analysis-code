clear;


animal = 'gh-rsc1'; % 'gh-rsc1' or  'sg-rat2'
day = 'day18'; % 'day18' or 'day01'
epType = 'sleep3'; % 'sleep3 or sleep2'
CTX = 'RSC'; % 'RSC' or 'CTX'

% 
% animal = 'sg-rat2';
% day = 'day01';
% epType = 'sleep2';
% CTX = 'PFC';

eegFileName = ['EEG_HPC_1500HZ_',CTX,'_250HZ_', upper(epType), '.mat']; 

edir = fullfile('/data', animal, day);

if ~exist(fullfile(edir, eegFileName), 'file')
    disp('Loading raw eeg');
   
    e = load_exp_eeg(edir, epType);
    [~, anat] = load_exp_eeg_anatomy(edir);
    ctxChanIdx = find( strcmp(anat, CTX) );
    hpcChanIdx = find( strcmp(anat, 'rCA1') );
    chanIdx = [ctxChanIdx(1) hpcChanIdx(1)];
    e.data = e.data(:, chanIdx);
    e.loc = e.loc(chanIdx);
    e.ch = e.ch(chanIdx);
    disp('Downsampling eeg');
    
    eegHpc = e.data(:,2);
    eegTs.hpc = e.ts;
    eegFs.hpc = e.fs;
    
    e = downsample_exp_eeg(e, 250);

    eegCtx = e.data(:,1);
    eegTs.ctx = e.ts;
    eegFs.ctx = e.fs;
    
    clear e;
    
    disp('Saving eeg');
    save(fullfile(edir, eegFileName), 'eegCtx','eegHpc', 'eegTs', 'eegFs')
else
    disp('Loading pre-downsampled eeg');
    load(fullfile(edir, eegFileName));
end
clear eegFileName
%%

spindleTimes = detect_spindles(eegTs.ctx, eegCtx);
rippleTimes = detect_ripples(eegTs.hpc, eegHpc);

%%
close all;
figure;
ax = axes;
l = line_browser(eegTs.ctx, eegCtx, 'Parent', ax(1));
s = seg_plot(spindleTimes, 'Axis', ax(1)); hold on;

uistack(l,'top');
%s = seg_plot(rippleEvents, 'Axis', ax(1));
set(s,'FaceAlpha', 1, 'FaceColor','r');
%%
close all;
figure;
ax = axes;
l = line_browser(eegTs.hpc, eegHpc, 'Parent', ax(1));
s = seg_plot(rippleTimes, 'Axis', ax); hold on;

uistack(l,'top');
%s = seg_plot(rippleEvents, 'Axis', ax(1));
set(s,'FaceAlpha', 1, 'FaceColor','r');

%%
fprintf('Filtering for spindles and ripples\n');
% spinFilt = getfilter(eegFs.ctx, 'spindle', 'win');
ripFilt = getfilter(eegFs.hpc, 'ripple', 'win');

% eegSpin = filtfilt(getfilter(eegFs.ctx, 'spindle', 'win'), 1, eegCtx);
eegRip = filtfilt(getfilter(eegFs.hpc, 'ripple', 'win'), 1, eegHpc);

% eegSpinEnv = abs(hilbert(eegSpin));
% eegSpinPow = eegSpin .^2;
eegRipPow = eegRip.^2; 
eegRipEnv = abs(hilbert(eegRip));

% tholdSpin = 3 * std(eegSpinPow);
tholdRip = 4 * std(eegRipEnv);

% isSpindle = eegSpinPow > tholdSpin;
isRipple = eegRipEnv > tholdRip;

% spindleEvents = detect_mountains(eegTs.ctx, eegSpinPow, 'threshold', tholdSpin);
rippleEvents = detect_mountains(eegTs.hpc, eegRipEnv, 'threshold', tholdRip);