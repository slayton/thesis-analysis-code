function position=load_position_old(session_dir, epoch_name, varargin)
% LOAD_POSITION(session_dir, epoch_name)
%
% loads position from position.p and linear position from linear_position.p
% if linear_position.p doesn't exist the user will be prompted to do the
% necessary actions to create linear_position.p
%
% depends upon PositionProcessing, MwlIO, and Utilties toolboxs

warning('load_position_old is depricated, please updated the position file.');
position = [];
%{
if numel(varargin)
    gui_force = 1;
else
    gui_force = 0;
end
%}
fields = {'timestamp', 'diode1', 'diode2', 'headpos', 'headdir'};

files = dir(fullfile(session_dir, 'epochs', epoch_name));
p_file_found = 0;
for i =1:length(files)
    if strcmp(files(i).name, 'position.p')
        p_file_found = 1;
        break;
    end
end
if ~p_file_found
    disp('No Position File Found!?!?, did you specify the correct path?');
    return;
end

disp('Loading position file!');
pos_file = mwlopen(fullfile(session_dir, 'epochs', epoch_name, 'position.p'));
position = load(pos_file, fields);

%% this is the obselete file, don't create linear_position.p create lin_pos
%% instead using the newer version of this file
%%
%{
if ~exist(fullfile(session_dir, 'epochs', epoch_name, 'linear_position.p')) || gui_force
    answer = questdlg('linear_position.p not found! Create it?', 'Huh?', 'Yes');
    if strcmp(answer, 'Yes')
        list = {'Linear', 'Circular', 'Spline', 'Complex'}; 
        n = track_selection(figure, position, 'PromptString', 'Select a track type:', 'SelectionMode', 'Single', 'ListString', list);
        linear_position = linearize_position(position.headpos(1,:), position.headpos(2,:), list{n}, 1);       
        calculate_velocity_gui(linear_position);
        f = gcf;
        ud = get(f, 'UserData');
        while ud(3)==0
            pause(.1);
            ud = get(f, 'UserData');
        end
        close(gcf);
        thold = ud(1);
        smooth_val = ud(2);
        velocity = calculate_velocity(linear_position, smooth_val, 1/30);
        direction = calculate_direction(velocity);
        position.linear_position = linear_position;
        position.linear_velocity = filter_linear_velocity(velocity);
               
        position.linear_direction = direction;
        position.units = 'meters';
        
        data = prepare_data(position.timestamp, linear_position, velocity, direction);
        save_linear_position(session_dir, epoch_name, data);      
              
    else
        disp('Linear position not loaded or created.');
    end
else
%}
    f = mwlopen(fullfile(session_dir, 'epochs', epoch_name, 'linear_position.p'));
    l = load(f);
    position.lin_pos = l.linear_position;
    position.lin_vel = l.linear_velocity;
    position.lin_dir = l.linear_direction;
    %position.info = fullfile(session_dir, epoch_name);
%end
    %{
function data = prepare_data(ts, l, v, d)
    ts = reshape(ts, max(size(ts)), min(size(ts)));
    l = reshape(l, max(size(l)), min(size(l)));
    v = reshape(v, max(size(v)), min(size(v)));
    d = reshape(d, max(size(d)), min(size(d)));
    
    data = {ts, l, v, d};
end

    function vel = filter_linear_velocity(vel)
                
        run_seg = logical2seg(vel~=0);
        run_ind = diff(run_seg, 1,2)<10;
        
        ind = run_seg(run_ind,:);
        for i=1:length(ind)
            vel(ind(i,1):ind(i,2)) = 0;
        end

    end
%}
end