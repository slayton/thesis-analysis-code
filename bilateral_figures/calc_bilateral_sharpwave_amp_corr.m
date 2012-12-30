clear;
dset = dset_load_all('Bon', 5, 3);
d = dset_calc_ripple_params(dset);
%%
r = d.ripples;
nRipple = numel(r.peakIdx);
ts = r.window / r.fs;

swWin = [-.05 .05];
ripWin = [-.01 .01];
swIdx = ts >= swWin(1) & ts<=swWin(2);
ripIdx = ts >= ripWin(1) & ts<=ripWin(2);

%% Compute the bilateral inst. freq correlations, compare to shuffled ripples

trig.instFreq = r.instFreq{1}(:, ripIdx);
ipsi.instFreq = r.instFreq{2}(:, ripIdx);
cont.instFreq = r.instFreq{3}(:, ripIdx);

corrIdx = ~isnan(trig.instFreq .* ipsi.instFreq .* cont.instFreq);

[freqCorr.ipsi, freqCorr.pIpsi]= corr(trig.instFreq(corrIdx(:)), ipsi.instFreq(corrIdx(:)));
[freqCorr.cont, freqCorr.pCont]= corr(trig.instFreq(corrIdx(:)), cont.instFreq(corrIdx(:)));


nShuffle = 1000;
for iShuffle = 1:nShuffle

    randIdx = randsample(nRipple, nRipple,1); 
   
   ipsiShuffle = ipsi.instFreq(randIdx,:);
   contShuffle = cont.instFreq(randIdx,:);
   
   corrIdx = ~isnan(trig.instFreq .* ipsiShuffle .*contShuffle);
   
   freqCorr.ipsiShuff(iShuffle) = corr( trig.instFreq(corrIdx(:)), ipsiShuffle(corrIdx(:)) );
   freqCorr.contShuff(iShuffle) = corr( trig.instFreq(corrIdx(:)), contShuffle(corrIdx(:)) );
   
end

freqCorr.ipsiPvalMC = max( sum( freqCorr.ipsiShuff > freqCorr.ipsi) / nShuffle, 1/nShuffle);
freqCorr.contPvalMC = max( sum( freqCorr.contShuff > freqCorr.cont) / nShuffle, 1/nShuffle);

figure; 
subplot(211);
hist(freqCorr.ipsiShuff, -.2:.01:.2); 
line(freqCorr.ipsi * [1 1], get(gca,'YLim'), 'Color', 'r', 'linewidth', 2);
title(sprintf('Ipsilateral Ripple Freq Corr: P<= %2.3f', freqCorr.ipsiPvalMC));

subplot(212);
hist(freqCorr.contShuff, -.2:.01:.2); 
line(freqCorr.cont * [1 1], get(gca,'YLim'), 'Color', 'r', 'linewidth', 2);
title(sprintf('Contralateral Ripple Freq Corr: P<= %2.3f', freqCorr.contPvalMC));

%% Compute the peak sw amplitude for each ripple event

[trig.swPeakAmp, ipsi.swPeakAmp, cont.swPeakAmp] = deal( zeros(nRipple, 1) );

for iRipple = 1:nRipple
    
    trig.swPeakAmp(iRipple) = max( r.sw{1}(iRipple,swIdx) );
    ipsi.swPeakAmp(iRipple) = max( r.sw{2}(iRipple,swIdx) );
    cont.swPeakAmp(iRipple) = max( r.sw{3}(iRipple,swIdx) );
      
end
    
    


