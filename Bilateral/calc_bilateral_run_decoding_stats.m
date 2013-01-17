function results = calc_bilateral_run_decoding_stats(d, varargin)

args.N_SHUF = 250;
args.PLOT = 0;
args.REPORT = 1;
args.DSET = 1;

args = parseArgs(varargin, args);
% %% Load the data and compute reconstruction
% clear;
% d = dset_load_all('Bon', 4,4);
%%
clearvars -except d args;
lIdx = strcmp( {d.clusters.hemisphere}, 'left');
rIdx = strcmp( {d.clusters.hemisphere}, 'right');

r(1) = dset_reconstruct(d.clusters(lIdx), 'time_win', d.epochTime, 'tau', .25, 'trajectory_type', 'simple');
r(2) = dset_reconstruct(d.clusters(rIdx), 'time_win', d.epochTime, 'tau', .25, 'trajectory_type', 'simple');

%% Get the two position PDFS with stopping periods removed

if args.DSET
    velThold = 15;
else
    velThold = .15;
end

runVel = interp1(d.position.ts, abs(d.position.smooth_vel), r(1).tbins, 'nearest');

isRunning = runVel > velThold;

p1 = r(1).pdf(:, isRunning);
p2 = r(2).pdf(:, isRunning);

nPbin = size(p1, 1);

validIdx = ~( all(p1 == nPbin^-1) | all(p2 == nPbin^-1) );

p1 = p1(:, validIdx);
p2 = p2(:, validIdx);

nTbin = nnz(validIdx);


if args.PLOT
    figure; 
    imagesc([p1; p2]);
end

%% Compute the Confusion Matrix, and its precision to within 30cm

[~, idx1] = max(p1);
[~, idx2] = max(p2);

cMat = confusionmat(idx1, idx2, 'order', 1:nPbin);

if args.DSET
    N = round( .3 / .05 );
end

tmp = ones(nPbin);
ind =  triu( tmp, -N) & tril( tmp, N ) ;


precision = sum(cMat(ind)) / nTbin ;

pShuf = nan(args.N_SHUF, 1);
for i = 1:args.N_SHUF
    
    idxShuf = randsample(idx2, nTbin, 1);
    cTmp = confusionmat(idx1, idxShuf, 'order', 1:nPbin);
    pShuf(i) = sum(cTmp(ind)) /nTbin;
end

pVal = sum( precision < pShuf ) / args.N_SHUF;

if args.REPORT == 1
    fprintf('Confusion Matrix Precision: %3.4f\tMC-pValue: %1.4f\n', precision, pVal);
end

if args.PLOT == 1
    figure;
    subplot(121); imagesc(cMat); 
    subplot(122); imagesc(cTmp);

    
    figure;
    ax = axes;
    [F, X, U] = ksdensity(pShuf, 'Width', .02);
    
    line(X, F, 'color', 'b');
    line(precision * [1, 1], max(F) * [0 1.1], 'color', 'r');
    set(ax, 'XLim', [0 1]);
end
    
results.N_SHUF = args.N_SHUF;
results.confusionMat.acc = precision;
results.confusionMat.pVal = pVal; 


%% Compute the distribution of correlations vs Null distributions

cReal = corr_col(p1, p2);

[cShufTime, cShufShift] = deal( nan(args.N_SHUF, numel(cReal)) );

nShift = randi(nTbin,1, args.N_SHUF);

for i = 1:args.N_SHUF
    
    randIdx = randsample(nTbin, nTbin);
    cShufTime(i,:) = corr_col(p1, p2(:, randIdx) );
    cShufShift(i,:) = corr_col(p1, circshift(p2, [0, nShift(i) ] ) );
    
end


[~, pValTime] = kstest2(cReal, cShufTime(:), .05, 'smaller');
[~, pValShift] = kstest2(cReal, cShufShift(:), .05, 'smaller');


if args.PLOT == 1

    ksArgs = { -1:.05:1, 'support', [-1.01 1.01], 'width', .25};
    [F1, X] = ksdensity( cReal, ksArgs{:} );
    [F2, X] = ksdensity( cShufTime(:), ksArgs{:} );
    [F3, X] = ksdensity( cShufShift(:), ksArgs{:} );
    
    figure;
    ax = axes();

    line(X, F1, 'Color', 'b');
    line(X, F2, 'Color', 'r');
    line(X, F3, 'Color', 'g');

    set(ax, 'XLim', [-1 1]);
    
end

if args.REPORT == 1
    fprintf('Col Correlation pV TB-Swap: %1.4g\tPDF-Shift: %1.4g\n', pValTime, pValShift);    
end

results.columnCorr.tbSwapPVal = pValTime;
results.columnCorr.pdfShiftPVal = pValShift;


results.columnCorr.realRange = quantile( cReal, [.25 .5 .75 ]);
results.columnCorr.tbSwapRange = quantile( cShufTime(:), [.25 .5 .75 ]);
results.columnCorr.pdfShiftRange = quantile( cShufShift(:), [.25 .5 .75]);


end