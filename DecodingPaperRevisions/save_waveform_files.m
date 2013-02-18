function save_waveform_files(baseDir)

MIN_VEL = .15;
MIN_WIDTH = 12;
MIN_AMP = 125;

if nargin==1
    plot = 0;
end

if ~exist(baseDir, 'dir')
    error('Dir %s does not exist', baseDir)
end

klustDir = fullfile(baseDir, 'kKlust');
if ~exist(klustDir, 'dir')
    mkdir(klustDir);
end
%%
ep = 'amprun';

p = load_exp_pos(baseDir, ep);

[ts, amp, width, waveform, ttList] = load_dataset_waveforms(baseDir, ep);
%%

data = repmat({}, size(ts));

for i = 1:numel(ts)
    
    t = ts{i};
    a = amp{i};
    w = width{i};
    wf = waveform{i};
    
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
    end
end
%%
   
save(fullfile(klustDir, 'spikes.mat'), 'data');
save(fullfile(klustDir, 'waveforms.mat'), 'waveform');
save(fullfile(klustDir, 'ttMap.mat'), 'ttList');

return;



