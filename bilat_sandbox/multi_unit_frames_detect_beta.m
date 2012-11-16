%%
% DATA SETS Showing some rhythmicity in the Multi-Unit bursts
%
% - Trigger on Burst START:
%   Bon 3:5  7:3
%   S11 13:2 14:2
%
%   Best --> 7:3, S11 13:2
%
% - Trigger on Burst END:
%   Bon 3:3 6:5 3:3 9:3 5:5 10:3 5:5
%   S11 13:s2
%
%   Best --> Bon 5:5 3:3  10:3
%
% - Trigger on Burst CENTER:
%   spl11 14:2
%   bon 3:3
%
%
%%
clear;
%%

epType = 'SLEEP';
if strcmp('RUN', epType)
    eList = dset_list_epochs('run');
elseif strcmp('SLEEP', epType)
    eList = dset_list_epochs('sleep');
else
    error('Invalid EP TYPE');
end

for iEpoch = 1:size(eList,1)
%     if ~exist('muRate', 'var') ||  isempty(muRate) 
        disp('Multi-unit and eeg not loaded yet, loading now');

            dset = dset_load_all(eList{iEpoch,1}, eList{iEpoch,2}, eList{iEpoch,3});
    %         eegTmp = dset.eeg(1);
            mu = dset.mu;

    %         eegTs = dset_calc_timestamps(eegTmp.starttime, numel(eegTmp.data), eegTmp.fs);

            if ~isfield(mu, 'rate')
                muRate = mu.rateL + mu.rateR;
            else
                muRate = mu.rate;
            end

            muBursts = mu.bursts;
            muTs = mu.timestamps;
            burstLen = diff(muBursts,[],2);
            burstIdx = find( burstLen > .4 );

            nBurst(iEpoch) = nnz(burstIdx);

%     end

muFs = mean(diff(mu.timestamps))^-1;

%%
% Get the length of the multi-unit bursts
burstLen = diff(muBursts,[],2);
burstIdx = find( burstLen > quantile(burstLen, .9) );

% [~, sIdx] = sort(burstLen);
% burstIdx = sIdx(end-10:end);

fprintf('Found %d bursts\n', numel(burstIdx));

% find the Multi-unit rate for the bursts
peakIdx = zeros(size(burstIdx));
for j = 1:numel(burstIdx)
    
    startIdx = find( muTs == muBursts(j, 1), 1, 'first');
    endIdx = find(muTs == muBursts(j,2), 1, 'first');
    
    [~, mIdx] = max( muRate(startIdx:endIdx) );
    peakIdx(j) = round(mean( [startIdx endIdx] ));% - 1 + mIdx;
    
end

% define the window in samples and time around the event


winLenTime = .5;
winLenSamp = winLenTime * muFs;
winSamp = -winLenSamp:winLenSamp;
winTime = 1000 * winSamp / muFs;

burstWin = bsxfun(@plus, peakIdx, -winLenSamp:winLenSamp );

% grab the samples
burstSamps = muRate(burstWin);
% compute the mean burstRAte
meanBurstRate = mean(burstSamps);


% Compute the peaks
[~, pkIdx] = findpeaks( meanBurstRate );
dPeaks = [nan diff(pkIdx)];
dPeakTime = dPeaks / muFs;
peakFreq = dPeakTime .^ -1;
pkTs = winSamp(pkIdx) * 1000/muFs;

figure('Position', [60+(iEpoch*20) 20+(iEpoch*20) 950 300]);
axes('Position', [.05 .1 .9 .75]);

for j = 1:numel(pkIdx)
    if j>1
        text(mean(pkTs([j-1 j])), 10, sprintf('%s:%2.1f', '\Deltat', 1000*dPeakTime(j)), 'horizontalalignment', 'center');    
    end
    line([pkTs(j) pkTs(j)], [0 10], 'color', [.4 .4 .4], 'linestyle', '--');
end
line(winTime, 10 * meanBurstRate/ max(meanBurstRate), 'color', 'r', 'linewidth', 2);

set(gca,'YLim', [0 11]);
title(sprintf('%s N Events:%d Trigger on:%s', dset_get_description_string(dset), nnz(burstIdx), ' BurstStart'));
end



