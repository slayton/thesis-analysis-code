function evaluate_place_cells(exp, varargin)

% EVALUATE_PLACE_CELLS(exp)
%exp = experiment struct
%   oringal_data 1 or 0, 1 signals that the experiment is freshly loaded an
%   unfiltered by an evaluated
%   force_hold 1 or 0, if set to 1 then the matlab environment is held
%   until this figure closes.
%
%% Globals
switch numel(varargin)
    case 0
        orig_data = 0;
        hold_force = 0;
    case 1
        orig_data = varargin{1};
        hold_force = 0;
    otherwise
        orig_data = varargin{1};
        hold_force = varargin{2};
end

epochs = exp.epochs;
epochs_sel_flag = false(size(epochs));
epoch =[];

clusters = [];
position = [];
cell_num = [];
cv1 = [];
cv2 = [];
m1 = [];
m2 = [];

if numel(varargin)>0
    hold_cli = varargin{1};
else
    hold_cli = 0;
end


%% Setup Ploting

f =figure();
%% Setup GUI
set(f, 'Position', [350 250 560 750]);
list_box = uicontrol('Style', 'listbox', 'Units', 'Normalized',...
    'Position', [.88 .06 .1 .86], 'CallBack', @list_selection);

save_btn = uicontrol('Style', 'PushButton', 'Units', 'normalized', ...
    'Position', [.81 .93 .18 .03], 'String', 'Save', 'CallBack', @save_cells_fn);

delete_btn = uicontrol('Style', 'PushButton', 'Units', 'normalized', ...
	'Position', [.62 .93 .18 .03], 'String', 'Delete Cell', 'CallBack', @delete_cell_fn);

next_btn = uicontrol('Style', 'PushButton', 'Units', 'normalized', ...
    'Position', [ .43 .93 .18 .03], 'String', 'Next Cell', 'CallBack', @next_cell_fn);

prev_btn = uicontrol('Style', 'PushButton', 'Units', 'normalized', ...
	'Position', [ .24 .93 .18 .03], 'String', 'Prev Cell', 'CallBack', @prev_cell_fn);


cell_lbl = uicontrol('Style', 'Text','String', 'n:', 'units', 'normalized',...
    'position', [0.02 .935 .15 .02],'backgroundcolor', [.8 .8 .8]);
cell_txt = uicontrol('Style', 'Text', 'String', 0, 'units', 'normalized',...
    'position', [0.17 .935 .05 .02], 'backgroundcolor', [.8 .8 .8]);

epoch_ui = uicontrol('Style', 'Popupmenu', 'String', epochs, 'units', 'normalized',...
    'Position', [.81 .965 .18 .03], 'Callback', @epoch_sel_fn);
new_clusters = [];

trunc_chk = uicontrol('Style', 'checkbox','String', 'Truncate Fields', 'Units', 'normalized', ...
    'position', [.06 .88 .21 .03], 'backgroundcolor', [.8 .8 .8], 'callback', @truncate_fields, 'value', 1);

trunc_npt = uicontrol('Style', 'edit', 'String', '2', 'units', 'normalized', ...
    'position', [.27 .88 .07, .03], 'callback', @truncate_fields);

a(1) = axes('Position', [0.06 0.49 0.76 0.35], 'XTick', [], 'YTick', [], 'Box', 'on');

a(2) = axes('Position', [0.06 0.24 0.76 0.215], 'XTick', [], 'YTick', [], 'Box' ,'on');

a(3) = axes('Position', [0.06 0.06 0.76 0.15], 'XTick', [], 'YTick', [], 'Box', 'on');

set(f, 'ToolBar', 'figure')


epoch_sel_fn();


while (hold_force && ishandle(f))
    pause(.25);
end


%% Call Backs
    function epoch_sel_fn(varargin)
       cv1 = [];
       cv2 = [];
       epoch = epochs{get(epoch_ui, 'Value')};
       epochs_sel_flag(get(epoch_ui, 'Value')) = 1;
       clusters = exp.(epoch).cl;
       position = exp.(epoch).pos;

       update_list();
    end
    function update_list(varargin)

        cl_list = {};
        for i=1:length(clusters) %#ok
            cl_list{i} = i; %#ok
      %      warning off;    %#ok
            cv1(i,:) = exp.(epoch).cl(i).tc1;
            cv2(i,:) = exp.(epoch).cl(i).tc2;
      %      warning on;     %#ok
        end
        set(list_box, 'String', cl_list, 'Value',1);
        list_selection();
    end
    function list_selection(varargin)
        cell_num = get(list_box, 'Value');
        update_plots();
    end
    function update_plots()
                    

        c = clusters(cell_num);
        warning off;    %#ok
        spike_pos.x = interp1(position.ts, position.xp, c.st, 'nearest');
        spike_pos.y = interp1(position.ts, position.yp, c.st, 'nearest');
        spike_pos.l = interp1(position.ts, position.lp, c.st, 'nearest');
        spike_pos.v = interp1(position.ts, position.lv, c.st, 'nearest');
        warning on;     %#ok
        
        spike_lp_dir1 = spike_pos.l(logical(spike_pos.v>0));
        spike_lp_dir2 = spike_pos.l(logical(spike_pos.v<0));
        
        % Top plot - Environment
        idx = sort(randsample(1:numel(position.xp), 2500));
        plot(position.xp(idx), position.yp(idx), '.b', 'markersize', 15, 'Parent', a(1)); hold(a(1), 'on');
        plot(spike_pos.x(spike_pos.v>.15), spike_pos.y(spike_pos.v>.15), 'r.', 'Parent', a(1)); 
        plot(spike_pos.x(spike_pos.v<.15), spike_pos.y(spike_pos.v<.15), 'g.', 'Parent', a(1));
        hold(a(1), 'off'); set(a(1), 'XTick', [], 'YTick', []); 

        % Middle Plot - Linear Track vs Time
        plot(position.lp, position.ts, 'Parent', a(2));
        hold(a(2), 'on'); 
        plot(spike_lp_dir1, c.st(spike_pos.v>0), 'r.', 'Parent', a(2));
        plot(spike_lp_dir2, c.st(spike_pos.v<0), 'g.', 'Parent', a(2));
        
        hold(a(2), 'off');
        set(a(2), 'XTick', [], 'YTick', []);
        
        % Bottom Plot - Fields
        %cl = c;
        n_bins = (max(position.lp) - min(position.lp))/.10;
        
        %cv1 = smoothn(cv1,1);
        %cv2 = smoothn(cv2,1);
         
        ax = min(position.lp):clusters(1).tc_bw:max(position.lp);
        %ax =min(position.lp):.01:max(position.lp);
        
        area(ax, cv1(cell_num,:), 'FaceColor', 'r', 'EdgeColor', 'r', 'Parent', a(3));
        hold(a(3), 'on');
        area(ax, -cv2(cell_num,:), 'FaceColor', 'g', 'EdgeColor', 'g', 'Parent', a(3));
        hold(a(3), 'off');
        set(a(3), 'XTick', [], 'XLim', [ax(1), ax(end)]);
        set(a(2),'XLim', [ax(1), ax(end)]);
        
        
        linkaxes(a(2:3), 'x');
        
    end
    function delete_cell_fn(varargin)
        ind = get(list_box, 'Value');

        update_plots();
    end
    function save_cells_fn(varargin)
        answer = 'Yes';
        if ~min(epochs_sel_flag)
            answer = questdlg('Not all epochs evaluated, save anyway?');
        end
        if strcmp('Yes', answer)
           
        end    
    end
    function my_close(varargin)
        
    end
    function next_cell_fn(varargin)
        cur_selection = get(list_box, 'Value');
        if cur_selection<length(clusters)
            set(list_box, 'Value', cur_selection+1);
            list_selection();
        end
    end

    function prev_cell_fn(varargin)
        cur_selection = get(list_box, 'Value');
        if cur_selection>1
            set(list_box, 'Value', cur_selection-1);
            list_selection();
        end
    end

    function truncate_fields(varargin)

        cv1 = m1;
        cv2 = m2;
        if get(trunc_chk, 'Value')
           n = str2num(get(trunc_npt, 'String'));
           cv1(:,1:n)=0;
           cv1(:,end+1-(1:n))=0;
           cv2(:,1:n)=0;
           cv2(:,end+1-(1:n))=0; 
        end
        list_selection();
    end

    function filter_clusters()
       
        fs = 10; %minimum field size of 10
        si = 4.5;%maximum spatial information
        mr = 50; %maximum rate of 
        mp =  2; %minimum peak rate
        
        for i=1:length(clusters)
            sis1 = spatialinfo(m1(i,:));
            sis2 = spatialinfo(m2(i,:));
            if ~((sum(m1(i,:))>fs || sum(m2(i,:))>fs)...  
                    && (sis1<si || sis2<si) ... 
                    && max(m1(i,:))<mr && max(m2(i,:))<mr ... %max rate can't be highter then 50
                    && (max(m1(i,:))>mp || max(m2(1,:))>mp))   % cell must have a minimum of peak rate of 3hz
                    %disp(i)

            end
        end
        
    end
    
    
end
 