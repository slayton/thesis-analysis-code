function process_dataset_waveform_file(baseDir)

klustDir = fullfile(baseDir, 'kKlust');

dsetFile = fullfile(klustDir, 'dataset.mat');

if ~exist( dsetFile, 'file')
    save_dataset_waveforms(baseDir);
else
    in = load(dsetFile);
    ts = in.ts;
    amp = in.amp;
    width = in.width;
    waveform = in.waveform;
end


   
for i = 1:numel(ts)
    
    t = ts{i};
    a = amp{i};
    w = width{i};
    wf = waveform{i};
    pc{i} = calc_waveform_princom(wf{i});
    
    if isempty(t) || isempty(a) || isempty(w) || isempty(wf)
        data{i} = [];
        waveform = [];
    else
        
        lp = interp1(p.ts, p.lp, t, 'nearest');
        lv = interp1(p.ts, p.lv, t, 'nearest');

        
        nanIdx = isnan(lp) | isnan(lv);
        runIdx = abs(lv) >= MIN_VEL;
        wideIdx = sum(w >= MIN_WIDTH,2) >= 2;% spikes where at least 2 channels are wider than MIN_WIDTH
        ampIdx = max(a,[],2) >= MIN_AMP;
        
        idx = ~nanIdx & runIdx & wideIdx & ampIdx;

        
        a = a(idx,:);
        t = t(idx);
        lp = lp(idx);
        lv = lv(idx);
        w = w(idx);
        wf = wf(:,:, idx);

        data{i} = [a, t, lp, lv, w];

        waveform{i} = wf;
        pc{i} = pc{i}(idx,:);
    end
end
save(fullfile(klustDir, 'spikes.mat'), 'data');
save(fullfile(klustDir, 'waveforms.mat'), 'waveform');
save(fullfile(klustDir, 'ttMap.mat'), 'ttList');
save(fullfile(klustDir, 'princomp.mat'), 'pc');

return;




end