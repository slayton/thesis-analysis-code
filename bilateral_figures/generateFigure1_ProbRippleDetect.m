function generateFigure1_ProbRippleDetect
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

boxplot( [pIpsiRun', pContRun', pIpsiSleep', pContSlp'] );






%%


% e = dset_load_eeg('Bon', 4, 5, 1:30);
d = dset_load_all('Bon', 4, 5);

%%
ts = dset_calc_timestamps(d.eeg(1).starttime, numel(d.eeg(1).data), d.eeg(1).fs);

figure;

ax = axes;
ii = 0;
for i = 1:numel(e) 
    
    if strcmp(e(i).area, 'CA1')
        
        if strcmp(e(i).hemisphere, 'left')
            c = 'r';
        else
            c = 'g';
        end
        line_browser(ts, e(i).data + 500 * ii, 'Parent', ax, 'color', c);
        ii = ii + 1;
    end
end
%%
set(ax, 'YLim', [-500 (ii+1)*500]);
%%
badTs = [5775 6320]
badIdx = interp1(1:numel(ts), ts, [5775 6320], 'nearest')


end