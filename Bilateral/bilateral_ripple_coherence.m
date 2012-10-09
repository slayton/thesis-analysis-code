%% Load the raw data from disk
clear;
clc;

DATA_SRC = 'rips'; % 'rips' or 'raw';
USE_REF = 1; % 0 or 1
EPOCH = 'run'; % 'run' or 'sleep'

data = dset_load_ripples(EPOCH, 0);

% Prepare the data for analysis
nAnimal = numel(data);
nRipple = sum( arrayfun(@(x) size(x.(DATA_SRC){1},1), data, 'UniformOutput', 1) );
nSample = size(data(1).window,2);

% allocate our variables
[ripBase, ripCont, ripShuf1]  = deal( zeros(nRipple, nSample) );


% Create the real data set
idx = 1;
for i = 1:nAnimal;
    n = size(data(i).(DATA_SRC){1}, 1);  % number of ripples for this animal
    ripBase( idx : idx+n - 1 , :) = data(i).(DATA_SRC){1};
    ripCont( idx : idx+n - 1 , :) = data(i).(DATA_SRC){3};
    idx = idx + n; 
end

% Create within animal shuffle data
idx = 1;
for i = 1:nAnimal
    n = size(data(i).(DATA_SRC){1}, 1); % number of ripples for this animal
    ripShuf1( idx : idx+n-1 , :) = data(i).(DATA_SRC){3}(randsample(n,n,1),:);
    idx = idx + n; 
end

% Create between animal shuffle data
ripShuf2= ripBase( randsample(nRipple, nRipple, 1), :);

clearvars idx n nSampPerRipple shuffleIndex i
%
winIdx = 101:501;

%% Setup arguments  for MSCOHERE
nfft = numel(winIdx) + 1;
noverlap = floor(nfft/4); 
fs = data(1).fs;

[rippleCoherence shuffleCoherence1 shuffleCoherence2] =  deal( zeros(nRipple, (nfft)/2 + 1) );
% compute the Frequency vector was we can't save it in a parfor loop
[~, F] = mscohere(ripBase(1,winIdx), ripCont(1,winIdx),[], noverlap, nfft, fs);

%% Calculate the Correlations
%Check to see if a matlab pool is already open
if matlabpool('size')<1
    matlabpool('open');
else
    sprintf('Matlab pool is already open with size:%d\n', matlabpool('size'));
end

disp('Computing ripple coherence, this might take a while! Go get some water!');
tic;
parfor i = 1:nRipple
    rippleCoherence(i,:)   = mscohere(ripBase(i,winIdx), ripCont(i,winIdx),[], noverlap, nfft, fs);
    shuffleCoherence1(i,:) = mscohere(ripBase(i,winIdx), ripShuf1(i,winIdx),[], noverlap, nfft, fs);
    shuffleCoherence2(i,:) = mscohere(ripBase(i,winIdx), ripShuf2(i,winIdx),[], noverlap, nfft, fs);
end
dt = toc;
fprintf('Done! That took %4.4f seconds!\n', dt);

mRipCo = mean( rippleCoherence );
mRipShCo1 = mean( shuffleCoherence1 );
mRipShCo2 = mean( shuffleCoherence2 );

sRipCo = std( rippleCoherence);
sRipShCo1 = std( shuffleCoherence1 );
sRipShCo2 = std( shuffleCoherence2 );

%% - Plot the results

figure('Position', [500 200 400 800]);
a = [ subplot(211); subplot(212)];
p = zeros(4,1);
l = zeros(4,1);

[p(1) l(1)] = error_area_plot(F, mRipCo, 3 * sRipCo/sqrt(nRipple) , 'Parent', a(1) );
[p(2) l(2)] = error_area_plot(F, mRipCo, 3 * sRipCo/sqrt(nRipple) , 'Parent', a(2) );

[p(3) l(3)] = error_area_plot(F, mRipShCo1, 3 * sRipShCo1/sqrt(nRipple) , 'Parent', a(1) );
[p(4) l(4)] = error_area_plot(F, mRipShCo2, 3 * sRipShCo2/sqrt(nRipple) , 'Parent', a(2) );

% set the limits on the axes
set(a, 'XLim', [0 350], 'YLim', [.1 .6]);

% style the error patches
set(p, 'LineStyle', 'none', 'FaceColor', [.4 .4 .4]);

%style the center lines
set(l, 'Color', 'k', 'LineWidth', 2 );


title(sprintf('Ripple Coherence ref: %d    src: %s', USE_REF, DATA_SRC) ,'Parent', a(1), 'FontSize', 14);

% % move the non shuffle coherence plot to the top
% uistack([e(1) p(1) ], 'top');
% uistack([e(2) p(2) ], 'top');



















