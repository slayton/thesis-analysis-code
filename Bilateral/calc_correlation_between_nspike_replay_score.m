
function results = calc_correlation_between_nspike_replay_score(d, s, r)

%%
[maxL mIdxL] = max(s.L.score2, [], 2);
[maxR mIdxR] = max(s.R.score2, [], 2);
    
idx = mIdxL;
idx(maxR > maxL) = mIdxR(maxR > maxL);

for i = 1:size(d.mu.bursts,1)
    timeIdx = r.L.tbins >= d.mu.bursts(i,1) & r.L.tbins <= d.mu.bursts(i,2);
    
    nL(i) = sum(sum(r.L.spike_counts(:,timeIdx)));
    nR(i) = sum(sum(r.R.spike_counts(:,timeIdx)));
    sL(i) = s.L.score2(i, idx(i));
    sR(i) = s.R.score2(i, idx(i));
   
end
%%
idx = ~isnan(nL) & ~isnan(nR) & ~isnan(sL) & ~isnan(sR);

cRealL = corr2(nL(idx), sL(idx));
cRealR = corr2(nR(idx), sR(idx));


nShuffle = 500;
for n = 1:nShuffle
    sShuf1 = randsample(sR(idx), sum(idx), 1);
    cShuffR(n) = corr2(nR(idx), sShuf1);
    sShuf2 = randsample(sL(idx), sum(idx), 1);
    cShuffL(n) = corr2(nL(idx), sShuf2);
end
results.left.nspike = nL;
results.right.nspike = nL;
results.left.scores = sL;
results.right.scores = sR;
results.left.corr = cRealL;
results.right.corr = cRealR;
results.left.shuffle = cShuffL;
results.right.shuffle = cShuffR;
%%
figure;


subplot(211);
plot(nL, sL,'.');
title('left')
xlabel('number of spikes');
ylabel('event score');

subplot(212); 
plot(nR, sR, '.');
title('right');
xlabel('number of spikes');
ylabel('event score');

plot_shuffles({cShuffL, cShuffR}, [cRealL, cRealR])


end