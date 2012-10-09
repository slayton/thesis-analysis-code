treatment = 'Baseline';
eeg_path = '/home/slayton/data/disk1/spl04/day0';
days = [01, 02, 03, 05, 06, 07, 08, 09];
which_file = 2;
which_channel = 1;

clear rips120; clear rips60; clear rips30;



for i=1:length(days)

    day = i;

    eegfile = strcat(eeg_path, num2str(days(day)), '/eeg/eeg', num2str(which_file), '_0', num2str(days(day)), '.eeg');

    if exist(eegfile)
        eegR = imcont('eegfile', eegfile, 'chans', [which_channel]);
        eeg.data = eegR.data(:,1);
        eeg.Fs = 750;
        eeg.data = downsample(eeg.data, ceil(eegR.samplerate/750));
        eeg.ripple = filterRipple(eeg.data, eeg.Fs);

        timestamps = 1:length(eeg.ripple);

        timestamps = timestamps';
        scaler = length(timestamps)/(eegR.tend - eegR.tstart);
        timestamps = (timestamps/scaler) + eegR.tstart;

        eeg.timestamps = timestamps;

        eeg.hilbert = abs(hilbert(eeg.ripple));
        xbar = mean(eeg.hilbert);
        sigma = std(eeg.hilbert);
        thold = xbar+3*sigma;

        eeg.rThold = eeg.ripple .* (eeg.hilbert> thold);

        rippleTimes = rippleDetect(eeg.rThold, eeg.timestamps);

        min(rippleTimes);
        max(rippleTimes);
%        plot(eeg.ripple);

        %plot(eeg.data); hold on; plot(eeg.ripple, 'r');
        %plot(eeg.data); hold on; plot(eeg.rThold, 'r');

        epoch.start = eeg.timestamps(1);
        epoch.end = eeg.timestamps(end);
%        hist(rippleTimes,epoch.start:60:epoch.end)
        %1*60*60+60*22+40 %time of injection in AD time 1:22:40 1*60*60 + 60*22+ 44

        %xLine = [4960 4960];  % This is the value calculated just above
        %yLine = [0 1000];
        %figure; hist(rippleTimes, epoch.start:60:epoch.end); title(strcat('Ripple Occurance in 60 Second Bins ',treatment));% hold on; line(xLine, yLine, 'LineStyle', '--', 'color', 'r'); axis([1700 8000 0 75]);
        %figure; hist(rippleTimes, epoch.start:30:epoch.end); title(strcat('Ripple Occurance in 30 Second Bins ', treatment));% hold on; line(xLine, yLine, 'LineStyle', '--', 'color', 'r'); axis([1700 8000 0 45]);
        %figure; hist(rippleTimes, epoch.start:120:epoch.end); title(strcat('Ripple Occurance in 120 Second Bins', treatment));% hold on; line(xLine, yLine, 'LineStyle', '--', 'color', 'r'); axis([1700 8000 0 150]);

<<<<<<< .mine
        rips(i).thirty = (hist(rippleTimes, epoch.start:30:epoch.end))*2;
        rips(i).sixty = (hist(rippleTimes, epoch.start:60:epoch.end));
        rips(i).one_twenty =(hist(rippleTimes, epoch.start:120:epoch.end))/2;
        figure; plot(smoothn(rips(i).sixty,3)); title(eegfile);
        title(strcat('Ripples 30sec bins, Day0', num2str(days(day))));
        else
            disp(strcat('File does not exist ', eegfile));
=======
        rips(i).thirty = (hist(rippleTimes, epoch.start:30:epoch.end))*2;
        rips(i).sixty = (hist(rippleTimes, epoch.start:60:epoch.end));
        rips(i).one_twentry=(hist(rippleTimes, epoch.start:120:epoch.end))/2;
        figure; plot(smoothn(rips(i).thirty,2)); title(eegfile);
        title(strcat('Ripples 30sec bins, Day_0', num2str(days(day))));
>>>>>>> .r1994
        end
end


%
% 1700 is the start time in AD time, 9000 is the end time in AD time
%
% the above values for the histograms above will absolutely have to be
% set by the user so that too much data isn't displayed and so that the
% data displays correctly in the correct window
%

% params.pad = 1;
% params.fpass = [75 300];
% params.tapers = [25 10];
% params.Fs = 750;
% movingwin = [5, .5];

% [S t f] = mtspecgramc(eeg.data, movingwin, params); 

% sTimes = 1:length(S);
% sScale = length(sTimes) / (max(eeg.timestamps) - min(eeg.timestamps));
% sTimes = (sTimes/ sScale) + min(eeg.timestamps);

% figure; plot_matrix(S,sTimes,f); hold on; line(xLine, yLine, 'LineStyle', '--', 'color', 'k');

% params.fpass = [1 50]; [S t f] = mtspecgramc(eeg.data, movingwin, params); 

% figure; plot_matrix(S,sTimes,f); hold on; line(xLine, yLine, 'LineStyle', '--', 'color', 'k');
