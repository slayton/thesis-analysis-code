function position=load_position(session_dir, epoch_name, varargin)
% LOAD_POSITION(session_dir, epoch_name)
%
% loads position from position.p and linear position from lin_pos.p
% if lin_pos.p doesn't exist the user will be prompted to do the
% necessary actions to create lin_pos.p
%
% depends upon PositionProcessing, MwlIO, and Utilties toolboxs

position = [];

if numel(varargin)
    gui_force = 1;
else
    gui_force = 0;
end
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

pos_file_path= fullfile(session_dir, 'epochs', epoch_name, 'position.p');
pos_file = mwlopen(pos_file_path);
disp([epoch_name, ': loading position file:',pos_file_path]);
position = load(pos_file, fields);

if ~exist(fullfile(session_dir, 'epochs', epoch_name, 'lin_pos.p')) || gui_force
    answer = questdlg('lin_pos.p not found! Create it?', 'Huh?', 'Yes');
    if strcmp(answer, 'Yes')
        list = {'Linear', 'Circular', 'Spline', 'Complex'}; 
        n = track_selection(figure, position, 'PromptString', 'Select a track type:', 'SelectionMode', 'Single', 'ListString', list);
        [lin_pos nodes] = linearize_position(position.headpos(1,:), position.headpos(2,:), list{n}, 1);       
        calculate_velocity_gui(lin_pos);
        f = gcf;
        ud = get(f, 'UserData');
        while ud(3)==0
            pause(.1);
            ud = get(f, 'UserData');
        end
        close(gcf);
        thold = ud(1); %#ok
        smooth_val = ud(2);
        velocity = calculate_velocity(lin_pos, smooth_val, 1/30);
        direction = calculate_direction(velocity);
        position.lin_pos = lin_pos;

        position.lin_vel = filter_linear_velocity(velocity);
               
        position.lin_dir = direction;
        position.units = 'meters';
        
        data = prepare_data(position.timestamp, lin_pos, velocity, direction);
        save_linear_position(session_dir, epoch_name, data);      
        %save_linear_nodes(fullfile(session_dir, 'epochs', epoch_name), nodes);
              
    else
        disp('Linear position not loaded or created.');
    end
else
    lin_pos_path = fullfile(session_dir, 'epochs', epoch_name, 'lin_pos.p');
    f = mwlopen(lin_pos_path);
    disp([epoch_name, ': loading linear_position file:', lin_pos_path]);
    l = load(f);    
    position.lin_pos = l.lin_pos;
    position.lin_vel = l.lin_vel;
    position.lin_dir = l.lin_dir;
    %position.nodes = load_linear_nodes(fullfile(session_dir, 'epochs', epochs_name));
%    disp(['Max Lin Pos:, ', num2str(max(l.lin_pos))]);
%    position.info = fullfile(session_dir, epoch_name);
end
    
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
end