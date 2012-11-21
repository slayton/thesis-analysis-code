clear


%%
if ~exist('allRipples','var')
    allRipples = dset_load_ripples;
end
epType = 'SLEEP';
if strcmp('RUN', epType)
    eList = dset_list_epochs('run');
    ripples = allRipples.run;
elseif strcmp('SLEEP', epType)
    eList = dset_list_epochs('sleep');
    ripples = allRipples.sleep;
else
    error('Invalid EP TYPE');
end
Fs = 1500;
ripWin = -750:750;
ripTrigMuaAll = [];


eps = 2;
%eps = 1:size(eList,1);
if ~exist('muRate', 'var') || ~exist('eeg','var') || ~exist('ts','var') || ~exist('fs','var') || ...
 isempty(muRate) || isempty(eeg) || isempty(ts) || isempty(fs)
    disp('Multi-unit and eeg not loaded yet, loading now');
    muRate = {};
    eeg = {};
    ts = {};
    fs = [];
    
    for iEpoch = eps%1:numel(ripples)
        
        dset = dset_load_all(eList{iEpoch,1}, eList{iEpoch,2}, eList{iEpoch,3});
        eegTmp = dset.eeg(1);
        mu = dset.mu;
        clear dset;
        eegTs = dset_calc_timestamps(eegTmp.starttime, numel(eegTmp.data), eegTmp.fs);
        if ~isfield(mu, 'rate')
            muRate{iEpoch} = interp1(mu.timestamps, mu.rateL + mu.rateR, eegTs);
        else
            muRate{iEpoch} = interp1(mu.timestamps, mu.rate, eegTs);
        end

        fs = eegTmp.fs;
        ts{iEpoch} = eegTs;
        eeg{iEpoch} = eegTmp.data;
    end
end
%%
muRateAll = [];
dtThresh = [250 250]; % in milliseconds
dIdxThresh = dtThresh * Fs/1000;
setIdxTrip= {};
setidxSing = {};
setWinTrip = {};
setWinSing = {};
for iEpoch = eps%:numel(ripples)
    
   if isempty(muRate{iEpoch})
        continue;
    end
    
    ripIdx = ripples(iEpoch).peakIdx;
    iri = [nan; diff(ripIdx)];
    
    tmpSetIdx1 = iri * nan;
    tmpSetIdx2 = iri * nan;

    for j = 1:numel(iri)-3
        if iri(j) > dIdxThresh(1)
            if iri(j+1) < dIdxThresh(2)
                if iri(j+2) < dIdxThresh(2)
                    tmpSetIdx1(j) = j;
                end
            else
                tmpSetIdx2(j) = j;
            end
        end
    end
    
    setIdxTrip{iEpoch} = tmpSetIdx1(~isnan(tmpSetIdx1));
    setIdxSing{iEpoch} = tmpSetIdx2(~isnan(tmpSetIdx2));
    setWinTrip{iEpoch} = bsxfun(@plus, ripIdx( setIdxTrip{iEpoch}), ripWin);
    setWinSing{iEpoch} = bsxfun(@plus, ripIdx( setIdxSing{iEpoch}), ripWin);
    
    mua = muRate{iEpoch}(setWinTrip{iEpoch});
    
    if isempty(muRateAll)
        muRateAll = mua;
    else
        muRateAll = [muRateAll; mua];
    end
    
    meanMua = smoothn( mean(mua), 2);
    
    meanMua = 10 * meanMua/max(meanMua);
    
    [~, pkIdx] = findpeaks(meanMua, 'MINPEAKDISTANCE', 10);
    
    dPeaks = [nan diff(pkIdx)];
    dPeakTime = dPeaks /fs;
    peakFreq = dPeakTime .^ -1;
    pkTs = ripWin(pkIdx) * 1000/fs;
    valIdx = pkTs>-50 & pkTs < 400;
    
    figure('Position', [400 400 950 300],'Name', ripples(iEpoch).description, 'NumberTitle', 'off');
    axes('Position', [.05 .1 .9 .75]);

    for i = 1:numel(pkIdx)      
        if i>1 && pkTs(i) > 0 && pkTs(i)<400
            text(mean(pkTs([i-1 i])), 10, sprintf('%s:%2.1f', '\Deltat', 1000*dPeakTime(i)), 'horizontalalignment', 'center');
        end
        if pkTs(i) > -50 && pkTs(i)<400
            line([pkTs(i) pkTs(i)], [0 10], 'color', [.4 .4 .4]);
        end
    end
    line(ripWin * 1000/Fs, meanMua);
    
    title(sprintf('%s nEvent:%d', ripples(iEpoch).description, nnz(setIdxTrip{iEpoch})));
    set(gca,'YLim', [0 11]);
    
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Plot the Ripple Triggered Multi-unit rate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

meanMuRate = smoothn( mean( muRateAll), 2);

[~, pkIdx] = findpeaks(meanMuRate, 'MINPEAKDISTANCE', 10);
dPeaks = [nan diff(pkIdx)];
dPeakTime = dPeaks /fs;
peakFreq = dPeakTime .^ -1;
pkTs = ripWin(pkIdx) * 1000/fs;

close all
axes('Position', [.05 .05 .9 .85]);
for i = 1:numel(pkIdx)      
    if i>1 && pkTs(i) > 0 && pkTs(i)<400
        text(mean(pkTs([i-1 i])), 10, sprintf('%s:%2.1f', '\Deltat', 1000*dPeakTime(i)), 'horizontalalignment', 'center');
    end
    if pkTs(i) > -50 && pkTs(i)<400
        line([pkTs(i) pkTs(i)], [0 10], 'color', [.4 .4 .4]);
    end
end
line(ripWin * 1000/Fs, meanMuRate)

fprintf('Freqs:');
fprintf('%2.2f ', peakFreq);
fprintf('\n');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Compute the Pre/Post burst LFP Spectrum 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

iEpoch = 2;

nTapers = 4;
hs = spectrum.mtm(nTapers);
set3Rip = setWinTrip{iEpoch};
set1Rip = setWinSing{iEpoch};

midIdx = round(size(set3Rip,2)/2);
preOffset = 75;
postOffset = -75; %%<------------- REMOVE ALL RIPPLE SAMPS FROM PRE
nSamp = 600;        %%<------------- SET N SAMP HERE

preIdx = (1:nSamp) + ( (midIdx - nSamp) - preOffset);
postIdx = (midIdx : midIdx+nSamp ) + postOffset;

specPre3 = [];
specPost3 = [];
specPre1 = [];
specPost1 = [];

lfpPre3 = eeg{iEpoch}(set3Rip(:, preIdx));
lfpPost3 = eeg{iEpoch}(set3Rip(:, postIdx));
lfpPre1 = eeg{iEpoch}(set1Rip(:, preIdx));
lfpPost1 = eeg{iEpoch}(set1Rip(:, postIdx));
freqs = [];

%%
for iRip = 1:size(set3Rip,1)
      
    psdPre3 =  psd(hs, lfpPre3(iRip,:),  'Fs', Fs);
    psdPost3 = psd(hs, lfpPost3(iRip,:), 'Fs', Fs);
    
    psdPre1 =  psd(hs, lfpPre1(iRip,:),  'Fs', Fs);
    psdPost1 = psd(hs, lfpPost1(iRip,:), 'Fs', Fs);
    
    if isempty(specPre3)
        specPre3 = psdPre3.Data;
        specPost3 = psdPost3.Data;
        specPre1 = psdPre1.Data;
        specPost1 = psdPost1.Data;
        
    else
        specPre3 = [specPre3, psdPre3.Data];
        specPost3 = [specPre3, psdPost3.Data];
        
        specPre1 = [specPre1, psdPre1.Data];
        specPost1 = [specPre1, psdPost1.Data];
    end  
    if isempty(freqs)
        freqs = psdPre3.frequencies;
    end
end

% transpose the matrices for later use
[specPre3, specPost3, specPre1, specPost1] = deal( specPre3', specPost3', specPre1', specPost1');



%% Plot the ratio of the spectra

figure('Position', [400 30 560 1000]);


ax(1) = subplot(311);
line(freqs,  mean(specPost1) ./ mean(specPre1), 'Color', 'r', 'linewidth', 2 );
set(gca,'XLim', [0 300]);
title('Post1:Pre1 Ratio');

ax(2) = subplot(312);
line(freqs,  mean(specPost3) ./ mean(specPre3) , 'Color', 'g', 'linewidth', 2 );
title('Post3:Pre3 Ratio');

ax(3) = subplot(313);
line(freqs,  mean(specPost3) ./ mean(specPost1) , 'Color', 'b', 'linewidth', 2 );
title('Post3:Post1 Ratio');
set(ax,'XLim', [0 300]);



%% Plot the Spectrums
figure;
clear ax;
ax(1) = subplot(211);
imagesc(freqs, 1:size(set3Rip,1), log(specPre3) );

ax(2) = subplot(212);
imagesc(freqs, 1:size(set3Rip,1), log(specPost3) );

set(ax,'YDir', 'normal');
%hpsd = psd(Hs, 

%%






