function [results] = calc_bilateral_ripple_coherence(DATA_SRC, REF, EPOCH)

if ~any( strcmp(DATA_SRC, {'rips', 'raw'} ) )
    error('Invalid data src, must be "rips" or "raw"');
end

if ~any( REF == [0 1] )
    error('Invalid ref option, must be 0 or 1');
end

if ~any( strcmp( EPOCH, {'run', 'sleep'}) )
    error('Invalid epoch, must be run or sleep');
end

data = dset_load_ripples(EPOCH, 1);

% Prepare the data for analysis
nAnimal = numel(data);
nRipple = sum( arrayfun(@(x) size(x.(DATA_SRC){1},1), data, 'UniformOutput', 1) );
nSample = size(data(1).window,2);

% allocate our variables
[ripBase, ripCont, ripShuf1]  = deal( zeros(nRipple, nSample) );

% Create the REAL data set
idx = 1;
for i = 1:nAnimal;
    n = size(data(i).(DATA_SRC){1}, 1);  % number of ripples for this animal
    ripBase( idx : idx+n - 1 , :) = data(i).(DATA_SRC){1};
    ripCont( idx : idx+n - 1 , :) = data(i).(DATA_SRC){3};
    idx = idx + n; 
end

% Create WITHIN animal SHUFFLE data
idx = 1;
for i = 1:nAnimal
    n = size(data(i).(DATA_SRC){1}, 1); % number of ripples for this animal
    ripShuf1( idx : idx+n-1 , :) = data(i).(DATA_SRC){1}(randsample(n,n,1),:);
    idx = idx + n; 
end

% Create BETWEEN animal SHUFFLE data
ripShuf2= ripBase( randsample(nRipple, nRipple, 1), :);

clearvars idx n nSampPerRipple shuffleIndex i
%%
%Check to see if a matlab pool is already open
if matlabpool('size')<1
    matlabpool('open');
else
    sprintf('Matlab pool is already open with size:%d\n', matlabpool('size'));
end

%winIdx = 1 : 601; 
winIdx = 201:401;

% Setup arguments  for MSCOHERE
nfft = 2 ^ nextpow2( numel(winIdx) );

nWindow = 8;
winLen = floor(numel(winIdx) / 4);

noverlap = floor(winLen / 4);

fs = data(1).fs;

coherenceArgs = {[],[],[],fs};
%coherenceArgs = {winLen, noverlap, nfft, fs};
% compute the Frequency vector was we can't save it in a parfor loop
%[~, F] = mscohere(ripBase(1,winIdx), ripCont(1,winIdx),[], noverlap, nfft, fs);


[coTemp, F] = mscohere(ripBase(1,winIdx), ripCont(1,winIdx),coherenceArgs{:});
[rippleCoherence, shuffleCoherence1, shuffleCoherence2] =  deal( zeros(nRipple, size(coTemp,1) ) );

% Calculate the Correlations

disp('Computing ripple coherence, this might take a while! Go get some water!');
tic;
parfor i = 1:nRipple
%     rippleCoherence(i,:)   = mscohere(ripBase(i,winIdx), ripCont(i,winIdx),[], noverlap, nfft, fs);
%     shuffleCoherence1(i,:) = mscohere(ripBase(i,winIdx), ripShuf1(i,winIdx),[], noverlap, nfft, fs);
%     shuffleCoherence2(i,:) = mscohere(ripBase(i,winIdx), ripShuf2(i,winIdx),[], noverlap, nfft, fs);
    rippleCoherence(i,:)   = mscohere(ripBase(i,winIdx), ripCont(i,winIdx), coherenceArgs{:});
    shuffleCoherence1(i,:) = mscohere(ripBase(i,winIdx), ripShuf1(i,winIdx), coherenceArgs{:});
    shuffleCoherence2(i,:) = mscohere(ripBase(i,winIdx), ripShuf2(i,winIdx), coherenceArgs{:});
end
dt = toc;
fprintf('Done! That took %4.4f seconds!\n', dt);

results.rippleCoherence = rippleCoherence;
results.shuffleCoherence{1} = shuffleCoherence1;
results.shuffleCoherence{2} = shuffleCoherence2;
results.F = F;
results.shuffleType = {'within animal', 'between animals'};

end



%% - Plot the results
















