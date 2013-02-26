function [T, WF, ttList] = load_all_waveforms_prefilter(baseDir, MIN_VEL, MIN_AMP, MIN_WIDTH)

if ~ischar(baseDir) || ~exist(baseDir, 'dir')
    error('baseDir must be a string and valid directory');
end

ep = 'amprun';

tt_dir = dir(fullfile(baseDir,'t*'));


nTT = numel(tt_dir);

ttList = cell(nTT, 1);

for i = 1 : nTT
    if tt_dir(i).isdir
        ttFile = sprintf('%s/%s/%s.tt', baseDir, tt_dir(i).name, tt_dir(i).name);
        if exist( ttFile, 'file')
            ttList{i} = tt_dir(i).name;
        end
    end
end

% remove un used cells due created by the dir command above
ttList = ttList( ~cellfun(@isempty, ttList ));
nTT = numel(ttList);


if numel(ttList) == 0
    error('No .tt files found in %s', baseDir);
end

pos = load_linear_position(baseDir);

%out = cell(size(unique({exp.(epoch).cl.tt})));

[en, et] = load_epochs(baseDir);
et = et( strcmp(ep, en), :);

[T, WF] = deal( cell(nTT,1) );

% p = load_exp_pos(edir, epoch);

fprintf('Saving intermediate file:\n');
for i = 1 : nTT
    
    tmpFile = sprintf('%s/%s/inter/%s_%d.mat', baseDir,'kKlust', ttList{i}, i);
    fprintf('\t%s\n', tmpFile);    
    
    ttFile = sprintf('%s/%s/%s.tt', baseDir, ttList{i}, ttList{i});
%     fprintf('\t%s\n', file);
    [waves, ts] = import_waveforms_from_tt_file(ttFile, 'idx',[],'time_range', et);  

    
    lv = interp1(pos.ts, pos.lv, ts, 'nearest');
    isMoving = abs(lv) >= MIN_VEL;
    w = calc_waveform_width(waves)';
    a = calc_waveform_peak_amp(waves)';
    
    
    wideIdx = mean( w >= MIN_WIDTH, 2 ) >= .5;% Spikes on atleast 1/2 of the channels must be wider than MIN_WIDTH
    ampIdx = max( a ,[],2) >= MIN_AMP;
    
    idx = isMoving & ampIdx' & wideIdx' & ~isnan(isMoving);
    
    ts = ts(idx);
    waves = waves(:, :, idx);
    save(tmpFile, 'waves', 'ts')
    clear waves ts lv width pkAmp idx;
end 

fprintf('Combining files\n');
for i = 1 : nTT
    tmpFile = sprintf('%s/%s/inter/%s_%d.mat', baseDir,'kKlust', ttList{i}, i);
    in = load(tmpFile);
    
    T{i} = in.ts';
    WF{i} = in.waves;
    
end


end



    
    