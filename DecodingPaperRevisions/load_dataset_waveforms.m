function [out, tt_list] = load_dataset_waveforms(edir, epoch, varargin)
%MAKE_TETRODE_MAPS creates spike amplitude by position vector for each
%tetrode in the experiment. 
%
% [spikes tt_id] = make_tetrode_maps(exp, epoch)  returns a  cell array of 
% nx8 matrices where columns 1:4 correspond to the spike amplitudes 
% across the 4 tetrode channels, 
%
% column 5 is the timestamp when the spike was recorded
% column 6 is the position at which the spike was recorded
% column 7 is the velocity of the animal when the spike was recorded
% column 8 is the width of the recorded spike
%
% tt_id is a cell array of tetrode ID's. if tt_id{1} = t01 then the all
% values in spikes{1} come from t01
%
% all tetrodes that have more than 1000 spikes in the specified epoch
% are used, it is up to the user to filter the spikes by
% velocity, minimum number of spikes etc...
%
% see also decode_amplitudes decode_clusters convert_cl_to_kde_format

MIN_VEL = .15;
MIN_WIDTH = 12;
MIN_AMP = 125;

% p = exp.(epoch).pos;

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

out = {};

p = load_exp_pos(edir, epoch);

for i=1:numel(tt_list)
%     disp(['Loading Amplitude data from tetrode:', tt_list{i}]);
    file = fullfile(edir, tt_list{i}, [tt_list{i}, '.tt']);
    [~, ts, pk, w] = load_tt_waveforms(file, 'idx',[],'time_range', et); 
    
    warning off; %#ok
    lp = interp1(p.ts, p.lp, ts, 'nearest');
    lv = interp1(p.ts, p.lv, ts, 'nearest');
    warning on; %#ok
    
    validIdx = ~isnan(lp) & ~isnan(lv);
   
    runIdx = abs(lv) >= MIN_VEL;
    wideIdx = w .* true;% >= MIN_WIDTH;
    ampIdx = max(pk) >= MIN_AMP;
    
    validIdx = runIdx & wideIdx & ampIdx & validIdx;

    o = [pk',ts',lp',lv',w'];
    out{i} = o(validIdx,:);
    
    
end 
      
fprintf('\n');
end



    
    