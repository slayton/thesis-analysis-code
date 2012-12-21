
dRealSlp = [ripFreqSleep.base, ripFreqSleep.ipsi, ripFreqSleep.cont];

for i = 1:100

    idx = randsample(numel(ripFreqSleep.cont), numel(ripFreqSleep.cont));
    dShufSlp= [ripFreqSleep.base, ripFreqSleep.ipsi(idx), ripFreqSleep.cont(idx)];

    c = corr(dShufSlp);
    
    cShuffSlp(i,1) = c(2);
    cShuffSlp(i,2) = c(3);
end

[c, p] = corr(dRealSlp);
cRealSlp = c(2:3);

dRealRun = [ripFreqRun.base, ripFreqRun.ipsi, ripFreqRun.cont];

for i = 1:100

    idx = randsample(numel(ripFreqRun.cont), numel(ripFreqRun.cont));
    dShufRun= [ripFreqRun.base, ripFreqRun.ipsi(idx), ripFreqRun.cont(idx)];

    c = corr(dShufRun);
    
    cShuffRun(i,1) = c(2);
    cShuffRun(i,2) = c(3);
end

[c, p] = corr(dRealRun);
cRealR = c(2:3);

%%
figure;
b = -.15:.0025:.15;
axes('NextPlot', 'add');
h1 = hist(cShuffRun(:,1), b);
h2 = hist(cShuffRun(:,2), b);

line(b, normr( smoothn(h1,3) ), 'color', 'r', 'linestyle', '--', 'linewidth', 2);
line(b, normr( smoothn(h2,3) ), 'color', 'b', 'linestyle', '--', 'linewidth', 2);




%%

figure;
axes('NextPlot', 'add');
plot(dRealRun(:,1), dRealRun(:,2),'.');
plot(dRealRun(:,1), dRealRun(:,3),'r.');


%%
freqBins = 150:3:225;

fd{1} = hist3(dRealRun(:,1:2), {freqBins, freqBins});
fd{2} = hist3(dRealRun(:,1:2:3), {freqBins, freqBins});

fd{3} = hist3(dRealSlp(:,1:2), {freqBins, freqBins});
fd{4} = hist3(dRealSlp(:,1:2:3), {freqBins, freqBins});



for i = 1:4
    tmp = log( smoothn(fd{i},3, 'correct', 1) + .00001 );
    tmp = tmp - min(tmp(:));
    tmp = tmp / max(tmp(:));
biFreqRunIpsi = hist3([ripFreqRun.base, ripFreqRun.ipsi], {freqBins, freqBins});
