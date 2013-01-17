
clear;

eList = dset_list_epochs('Run');
nEpoch = size(eList, 1);


for i = 1:nEpoch
    
    fprintf('\n');
    d = dset_load_all(eList{i,:});
    results(i) = calc_bilateral_run_decoding_stats(d, 'PLOT', 0);
end
%%
clear; 
e = exp_load('/data/spl11/day15/', 'epochs', 'run', 'data_types', {'clusters', 'pos'});
e = process_loaded_exp2(e, [1, 7]);
%%
[r1, pf] = dset_reconstruct(e.run.cl, 'time_win', e.run.et, 'tau', .25, 'trajectory_type', 'simple');
[r2, tc] = exp_reconstruct(e, 'run', 'directional', 0);
%%

cm = [results.confusionMat];
cc = [results.columnCorr];

cReal = cell2mat( {cc.realRange}' );
cShift = cell2mat( {cc.pdfShiftRange}' );
cSwap = cell2mat( {cc.tbSwapRange}' );

boxplot([cReal(:,2), cShift(:,2), cSwap(:,2)])

pVal1 = signrank(cReal(:,2), cShift(:,2));
pVal2 = signrank(cReal(:,2), cSwap(:,2));

fprintf('Sign Ranksum vs shift:%0.7f vs swap:%0.7f\n', pVal1, pVal2)




