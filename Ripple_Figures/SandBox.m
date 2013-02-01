clear;
%{'spl11', 'spl11', 'spl11'}, [15 12 11], [2 1 2];
base = {'gh-rsc1', 'gh-rsc2', 'spl11'};
bId = [1 1 1 1 2 2 2 2 2];
day = [18, 22, 23, 24, 22, 24, 25, 26];
ep = [3, 1, 1, 2, 3, 3, 3, 3];

C = [];
H = [];
hpcIPI = [];
ctxIPI = [];
fprintf('\n\n');

for E = 1:4
    
    epoch = sprintf('sleep%d', ep(E));
    edir = sprintf('/data/%s/day%d', base{bId(E)}, day(E));
    fName = sprintf('MU_HPC_RSC_%s.mat', upper(epoch));
    fprintf('Loading:%s\n', fullfile(edir, fName));
    mu = load( fullfile(edir, fName) );
    mu = mu.mu;

    muBursts = find_mua_bursts(mu);
    bLen = diff(muBursts, [], 2);
    nBurst = size(muBursts,1);

    fprintf('Loaded %d bursts', nBurst); 

    thold = [.25 ];
    
    if numel(thold)==1
        idx = find( bLen > thold(1) );
    else
        idx = find( bLen > thold(1) & bLen < thold(2) );
    end
    
    nBurst = numel(idx);

    fprintf(', keeping %d\n', nBurst);

    hpcPkIdx = [];

    for i = 1:numel(idx)
       b = muBursts(idx(i),:);

       startIdx = find( b(1) == mu.ts, 1, 'first');

       r = mu.hpc( mu.ts>=b(1) & mu.ts <= b(2) );

       [~, pk] = findpeaks(r);
       pk = pk + startIdx -1;
%        pk = startIdx;
       hpcPkIdx = [hpcPkIdx, pk(1)];  %#ok
    end

    isBurstingIdx = seg2binary(muBursts, mu.ts);
    [~, allPksHPC] = findpeaks(mu.hpc .* isBurstingIdx);
    hpcIPI = [hpcIPI, diff( mu.ts(allPksHPC) );];
    
    [~, allPksCTX] = findpeaks(mu.ctx .* isBurstingIdx);
    ctxIPI = [ctxIPI, diff( mu.ts(allPksCTX) );];
    
    
    win = [-.5 .5];
    [mHpc, ~, ts, sampHpc] = meanTriggeredSignal(mu.ts(hpcPkIdx), mu.ts, mu.hpc, win);
    [mCtx, ~, ts2, sampCtx]= meanTriggeredSignal(mu.ts(hpcPkIdx), mu.ts, mu.ctx, win);

    mHpc = mHpc ./ max(mu.hpc(isBurstingIdx));
    mCtx = mCtx ./ max(mu.ctx(isBurstingIdx));
    
    H = [H; mHpc];
    C = [C; mCtx];
    
   
    
end


hpcIPI = hpcIPI(hpcIPI<.5);
ctxIPI = ctxIPI(ctxIPI<.5);
[fHPC, xHPC] = ksdensity(hpcIPI, 0:.005:.5);
[fCTX, xCTX] = ksdensity(ctxIPI, 0:.005:.5);

%%
figure('Position', [300 500 800 300]);
h = mean(H,1); h = h - min(h); h = h ./ max(h);
c = mean(C,1); c = c - min(c); c = c ./ max(c)/3;

ax(1) = axes('Position', [.05 .1 .6 .75]);
ax(2) = axes('Position', [.7 .1 .25 .75]);

line(ts, h, 'Color', 'r','Parent', ax(1));
line(ts2, c, 'Color', 'b','Parent', ax(1));

line(xHPC, fHPC, 'Color', 'r', 'Parent', ax(2));
line(xCTX, fCTX, 'Color', 'b', 'Parent', ax(2));


set(ax(1),'Xlim', [-.5 .5], 'YTick', [], 'Xtick', [-.5:.1:.5])
set(ax(2),'Xlim', [0 .25]);

title(ax(1), sprintf('Thold %dms - %dms', thold * 1000), 'fontSize', 16);
%%

clear;
load /data/gh-rsc1/day18/sleep2.1500hz.mat
T = ts;
E = eeg(10,:);
eeg = E;

%%

clear;
load /data/gh-rsc1/day18/sleep3.1500hz.mat
T = ts;
E = eeg(10,:);
eeg = E;

Fs = 1500;
X = double(E);

%%

clear;
load /data/gh-rsc1/day18/sleep4.1500hz.mat
T = ts;
E = eeg(10,:);
eeg = E;

badIdx = isnan(E);
T = T(~badIdx);
E = E(~badIdx);

Fs = 1500;
X = double(E);

%%

