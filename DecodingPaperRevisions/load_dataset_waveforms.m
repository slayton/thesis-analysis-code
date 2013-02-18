function [T, A, W, WF, tt_list] = load_dataset_waveforms(edir, epoch, varargin)

tt_dir = dir(fullfile(edir,'t*'));
tt_list = {};

for i=1:numel(tt_dir)
    if tt_dir(i).isdir
        if exist(fullfile(edir, tt_dir(i).name, [tt_dir(i).name, '.tt']))
            tt_list{end+1} = tt_dir(i).name;
        end
    end
end


%out = cell(size(unique({exp.(epoch).cl.tt})));

[en, et] = load_epochs(edir);
et = et( strcmp(epoch, en), :);

[T, A, W, WF] = deal({});

% p = load_exp_pos(edir, epoch);

fprintf('Loading data for:');
for i=1:numel(tt_list)
    
    fprintf('%s ', tt_list{i});
    file = fullfile(edir, tt_list{i}, [tt_list{i}, '.tt']);
    [waves, ts, pk, w] = load_tt_waveforms(file, 'idx',[],'time_range', et); 
    
%     warning off; %#ok
%     lp = interp1(p.ts, p.lp, ts, 'nearest');
%     lv = interp1(p.ts, p.lv, ts, 'nearest');
%     warning on; %#ok
%     
%     validIdx = ~isnan(lp) & ~isnan(lv);
%    
%     runIdx = abs(lv) >= MIN_VEL;
%     wideIdx = w >= MIN_WIDTH;
%     ampIdx = max(pk) >= MIN_AMP;
%     
%     validIdx = runIdx & wideIdx & ampIdx & validIdx;
% 
%     o = [pk',ts',lp',lv',w'];
%     out{i} = o(validIdx,:);
    

    T{i} = ts';
    A{i} = pk';
    W{i} = w';
    WF{i} = waves;
    
end 
fprintf('\n');

end



    
    