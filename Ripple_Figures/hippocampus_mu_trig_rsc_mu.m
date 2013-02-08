clear;
%{'spl11', 'spl11', 'spl11'}, [15 12 11], [2 1 2];
base = {'gh-rsc1', 'gh-rsc2', 'spl11'};
bId = [1 1 1 1 2 2 2 2];
day = [18, 22, 23, 24, 22, 24, 25, 26];
ep = [3, 1, 1, 2, 3, 3, 3, 3];

thold = .250;
win = [-.25 .5];

[hpcRateAll, ctxRateAll] = deal([]);

fprintf('\n\n');

for E = 1:8
    
    % LOAD THE DATA
    epoch = sprintf('sleep%d', ep(E));
    edir = sprintf('/data/%s/day%d', base{bId(E)}, day(E));
    fName = sprintf('MU_HPC_RSC_%s.mat', upper(epoch));
    fprintf('Loading\t:%s', fullfile(edir, fName));
    mu = load( fullfile(edir, fName) );
    mu = mu.mu;
    
    fName = sprintf('EEG_HPC_1500_%s.mat', epoch);
    fprintf('\t%s\n', fullfile(edir, fName));
    eeg = load( fullfile(edir, fName) );
    eeg = eeg.hpc;
    
    % DETECT SWS, Ripples, and MU-Bursts
    [sws, ripTs] = classify_sleep(eeg.ripple, eeg.rippleEnv, eeg.ts);
    muBursts = find_mua_bursts(mu);
    cFrames = find_ctx_frames(mu);
    nBurst = size(muBursts,1);

    muBursts = seg_and(muBursts, cFrames);
    fprintf('Loaded %d MU-Bursts', nBurst); 
    
    
    % Filter MU-Bursts
    burstLen = diff(muBursts, [], 2);
    burstLenIdx = burstLen > thold;
    
    muBursts = muBursts(burstLenIdx,:);
    nBurst = size(muBursts,1);
    fprintf(', keeping %d\n', nBurst);
    if nBurst < 2
        continue;
    end

    % Classify burst by SWS state
%     swsIdx = inseg(sws, muBursts, 'partial');

    muPkIdx = [];

    for i = 1:nBurst
        
       b = muBursts(i,:);

       startIdx = find( b(1) == mu.ts, 1, 'first');

       r = mu.hpc( mu.ts>=b(1) & mu.ts <= b(2) );

       [~, pk] = findpeaks(r); % <------- FIRST LOCAL MAX
%       [~, pk] = max(r);   % <------ GLOBAL MAX
       
       if numel(pk)<1
           continue
       end
       pk = pk + startIdx -1;
       muPkIdx = [muPkIdx, pk(1)];  %#ok
       
    end
    
    
    
    [mHpc, ~, ts, sampHpc] = meanTriggeredSignal( mu.ts( muPkIdx ), mu.ts, mu.hpc, win);
    [mCtx, ~, ts2, sampCtx]= meanTriggeredSignal( mu.ts( muPkIdx ), mu.ts, mu.ctx, win);
     
    hpcRateAll = [hpcRateAll; mHpc];
    ctxRateAll = [ctxRateAll; mCtx];   
         
end


%%
figure('Position', [300 500 800 300]);
ax(1) = axes('Position', [.1 .15 .8 .75]);
ax(2) = axes('Position', [.1 .15 .8 .75], 'color', 'none','yaxislocation', 'right');

xlabel(ax(1),'Time(ms)');
ylabel(ax(1), 'HPC Rate(Hz)');
ylabel(ax(2), 'RSC Rate(Hz)');

yTmp = minmax( mean(hpcRateAll) );
line([0 0], yTmp,  'color', [.7 .7 .7], 'linestyle', '--', 'parent', ax(1));
line(thold * [1000 1000], yTmp,  'color', [.7 .7 .7], 'linestyle', '--', 'parent', ax(1));


l(1) = line(ts*1000, mean(hpcRateAll,1), 'Color', 'r','Parent', ax(1));
l(2) = line(ts2*1000, mean(ctxRateAll,1), 'Color', 'b','Parent', ax(2));


legend(l(1:2), {'HPC', 'RSC'});

% line(xHPC, fHPC, 'Color', 'r', 'Parent', ax(2));
% line(xCTX, fCTX, 'Color', 'b', 'Parent', ax(2));


set(ax,'Xlim', win*1000, 'Xtick', [-250:250:500])

% set(ax(2),'Xlim', [0 .25]);

title(ax(1), sprintf('Thold %dms', thold * 1000), 'fontSize', 16);
%%

