function save_dataset_waveforms(baseDir)

MIN_VEL = .05;
MIN_WIDTH = 12;
MIN_AMP = 75;

if ~exist(baseDir, 'dir')
    error('Dir %s does not exist', baseDir)
end

klustDir = fullfile(baseDir, 'kKlust');
if ~exist(klustDir, 'dir')
    mkdir(klustDir);
end

%% - Save complete data file

dsetFileTs = sprintf('%s/dataset_ts.mat');
dsetFileTemplate = fullfile(klustDir, 'dataset_%s.mat');
if ~exist(dsetFileTs, 'file')
    
    ep = 'amprun';

    p = load_exp_pos(baseDir, ep);
    
    [ts, amp, width, waveform, ttList] = load_dataset_waveforms(baseDir, ep);

    lp = repmat({}, size(ts));
    lv = repmat({}, size(ts));
    
    for i = 1:numel(ts)
        t = ts{i};
        
        lp{i} = interp1(p.ts, p.lp, t, 'nearest');
        lv{i} = interp1(p.ts, p.lv, t, 'nearest');
        
        nanIdx = isnan(lv{i}) | isnan(lp{i});
        runIdx = abs(lv{i}) >= MIN_VEL;
        wideIdx = sum(width{i} >= MIN_WIDTH,2) >= 2;% spikes where at least 2 channels are wider than MIN_WIDTH
        ampIdx = max(amp{i},[],2) >= MIN_AMP;

        idx = ~nanIdx & runIdx & wideIdx & ampIdx;
        
        ts{i} = ts{i}(idx);
        lp{i} = lp{i}(idx);
        lv{i} = lv{i}(idx);
        
        amp{i} = amp{i}(idx, :);
        wide{i} = width{i}(idx);
        waveform{i} = waveform{i}(:,:,idx);
        
    end
    
    vars = {'ts', 'lp', 'lv', 'amp', 'wide', 'waveform', 'ttList'};
    
    for iVar = 1:numel(vars)
        f = sprintf( '%s/dataset_%s.mat', klustDir, vars{iVar} );
        fprintf('Saving %s\n', f);
        save(f,  vars{iVar} );
    end
end








