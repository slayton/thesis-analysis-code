function [pir, pcr, pis, psc] = generateFigure1_ProbRippleDetect
%%
clear;
fprintf('Loading Sleep\n');
eList = dset_list_epochs('sleep');

for iEpoch = 1:size(eList,1)
    
    fprintf('%d of %d\n', iEpoch, size(eList,1));
    d = [];
    if strcmp(eList{iEpoch, 1}, 'spl11')
        if strcmp( eList{iEpoch, 2}, 'day11')
            e = dset_exp_load_eeg('/data/spl11/day11', 'sleep2');
        else
            e = dset_exp_load_eeg('/data/spl11/day12', 'sleep3');
        end
        d.eeg = e;
    else
        d = dset_load_all(eList{iEpoch,:}, 'mu', 0);
    end
    
    pk = {};
    win = {};
    for iCh = 1:3
        [~, pk{iCh}, win{iCh}] = dset_calc_ripple_times(d, 'ripChan', iCh);
    end
    
    nTrig = size(win{1},1);
    pIpsiSlp(iEpoch) = nnz( inseg( win{2}, win{1}, 'partial' ) ) / nTrig;
    pContSlp(iEpoch) = nnz( inseg( win{3}, win{1}, 'partial' ) ) / nTrig;
    
end



eList = dset_list_epochs('run');

fprintf('Loading Run\n');
for iEpoch = 1:size(eList,1)
    
    fprintf('%d of %d\n', iEpoch, size(eList,1));
    d = [];
    if strcmp(eList{iEpoch, 1}, 'spl11')
        if strcmp( eList{iEpoch, 2}, 'day11')
            e = dset_exp_load_eeg('/data/spl11/day11', 'run');
        else
            e = dset_exp_load_eeg('/data/spl11/day12', 'sleep2');
        end
        d.eeg = e;
    else
        d = dset_load_all(eList{iEpoch,:});
    end
    
    pk = {};
    win = {};
    for iCh = 1:3
        [~, pk{iCh}, win{iCh}] = dset_calc_ripple_times(d, 'ripChan', iCh);
    end
    
    nTrig = size(win{1},1);
    pIpsiRun(iEpoch) = nnz( inseg( win{2}, win{1}, 'partial' ) ) / nTrig;
    pContRun(iEpoch) = nnz( inseg( win{3}, win{1}, 'partial' ) ) / nTrig;
    
end
%%
pir = pIpsiRun; 
pcr = pContRun;
pis = pIpsiSlp;
pcs = pContSlp;

boxplot( [pIpsiRun', pContRun', pIpsiSleep', pContSlp'] );

end