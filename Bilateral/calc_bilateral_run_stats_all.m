
clear;

eList = dset_list_epochs('Run');
nEpoch = size(eList, 1);



for i = 1:nEpoch
    
    fprintf('\n');
    d = dset_load_all(eList{i,:});
    results(i) = calc_bilateral_run_decoding_stats(d, 'PLOT', 0);

end


for i = 12:16
    numel(results);
    fprintf('\n');
    animal =  sprintf('/data/spl11/day%d', i); 

    try
        e = exp_load( animal, 'epochs', 'run', 'data_types', {'pos', 'clusters'});
        e = process_loaded_exp2(e, [1 7]);
    catch
        e = exp_load( animal, 'epochs', 'run2', 'data_types', {'pos', 'clusters'});
        e = process_loaded_exp2(e, [1 7]);
        e.run = e.run2;
        e = rmfield(e, 'run2');
    end
%     e = process_loaded_exp2(e, [1 7]);
    
     
    results(nRes+1) = calc_bilateral_run_decoding_stats(e.run, 'PLOT', 1, 'DSET', 0);
end


%%

cm = [results.confusionMat];
cc = [results.columnCorr];

cReal = cell2mat( {cc.realRange}' );
cShift = cell2mat( {cc.pdfShiftRange}' );
cSwap = cell2mat( {cc.tbSwapRange}' );

tmpData = [cReal(:,2), cShift(:,2), cSwap(:,2)];
boxplot(tmpData)

pVal1 = ranksum(cReal(:,2), cShift(:,2));
pVal2 = ranksum(cReal(:,2), cSwap(:,2));

hold on;
plot(1:3, tmpData, 'color', [.4 .4 .4]);


fprintf('Sign Ranksum vs shift:%0.7g vs swap:%0.7g\n', pVal1, pVal2)




