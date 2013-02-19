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
parfor i = 1 : numel(tt_list)
    
    fprintf('%s ', tt_list{i});
    file = fullfile(edir, tt_list{i}, [tt_list{i}, '.tt']);
    [waves, ts, pk, w] = load_tt_file_waveforms(file, 'idx',[],'time_range', et);  

    T{i} = ts';
    A{i} = pk';
    W{i} = w';
    WF{i} = waves; 
    
end 
fprintf('\n');

end



    
    