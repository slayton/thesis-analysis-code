function valid_chan = evaluate_eeg(exp, varargin)
%  valid_channels = evaluate_eeg(exp, original_data, force_hold)
%   exp = experiment struct
%   oringal_data 1 or 0, 1 signals that the experiment is freshly loaded an
%   unfiltered by an evaluated
%   force_hold 1 or 0, if set to 1 then the matlab environment is held
%   until this figure closes.
%

%%% GLOBALS
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


f = figure('position', [500 300 1000 800]);
set(f, 'Toolbar', 'figure');
%u = uiwrapper(f);
%u.DeleteFcn = @delete_all;
MAX_X = .915;
MAX_Y = .965;
n_chan = 0;
for i=1:length(exp.epochs)
    n_chan = max(length(exp.(exp.epochs{i}).eeg), n_chan); %add one for hilbert
end

valid_chan = [];
chan_check = [];
a = [];
eb = [];
wb = [];
p = [];

sources = load_signals(exp.session_dir);

%%%% Epoch Button Groups
epoch_sel_ui = uicontrol('Style','popupmenu', 'Units', 'Normalized', ...
    'Position', [.8 .9 .2 .1],'callback', @epoch_changed, 'String', exp.epochs);

%%% Save & Exit Button
load_btn = uicontrol('Style', 'Pushbutton', 'String' , 'Load', ...  
           'Units', 'Normalized', 'Position', [0, MAX_Y, .075, 1-MAX_Y], ...
           'CallBack', @my_load);
save_btn = uicontrol('Style', 'PushButton', 'String' , 'Save', ...
           'Units', 'Normalized', 'Position', [.075, MAX_Y, .075, 1-MAX_Y],...
           'Callback', @my_save);
close_btn = uicontrol('Style', 'PushButton', 'String', 'Close',...
           'Units', 'Normalized', 'Position', [.15, MAX_Y, .075 1-MAX_Y],...
           'CallBack', @my_close);     %#ok  

%%% Channel Checkboxes
set(epoch_sel_ui(1), 'value', 1);
epoch = exp.epochs{1};
make_check_box();
epoch_changed();
update_colors();

if mod(numel(valid_chan),8) || ~orig_data
    disp('Data doesnt appear to be orignal, use orig_data trigger or provide data with a 8xN channels');
    set(save_btn, 'Enable', 'Off');
    set(load_btn, 'Enable', 'Off');
end

pan('xon');
zoom('xon');
%%% Setup AXES objects
%update_plots();
if orig_data
    my_load()
end

while hold_force && ishandle(f)
    pause(.125);
    
end

    function make_check_box()
        if isempty(valid_chan)
           valid_chan = logical(1:n_chan);
        end
        %disp('Make Check Box');
        dy = MAX_Y/(n_chan);
        for i=1:n_chan
            
            name = exp.(epoch).eeg(i).name;
            ind = cellfun(@strcmp, sources(:,1), repmat({name}, size(sources(:,1))));
            electrode = sources{ind,2};
            
            chan_check(i) = uicontrol('Style', 'Checkbox', 'String', [electrode], ...
                'Units', 'Normalized', 'Position', [MAX_X, MAX_Y-(i*dy), 1-MAX_X, dy], ...
                'Value', valid_chan(i), 'CallBack', @check_box_clicked, 'UserData', i);
        end
        
    end
    function check_box_clicked(source, eventdata)
        index =get(source, 'UserData');
        valid_chan(index) = ~valid_chan(index);
        update_colors();
    end
    function update_colors()
        %disp('Updating Colors');
        for i=1:n_chan
            switch valid_chan(i)
                case 1
                    set(p(i),'Color', 'b')
                case 0 
                    set(p(i),'Color', 'r')
            end
        end
    end

    function create_plots()
        %disp('Create Plots');
        ind = 1:35000;
        for i=1:n_chan
            dy = MAX_Y/n_chan;
            a(i) = axes('Units', 'Normalized', 'Position', [0, MAX_Y-(i*dy), MAX_X, dy]);
            %p(i) =  plot(exp.(epoch).eeg_ts(ind), exp.(epoch).eeg(i).data(ind), 'Parent', a(i));
            p(i) =  line_browser(  exp.(epoch).eeg(i).data(ind) ,exp.(epoch).eeg_ts(ind), a(i));
            
            set(a(i), 'XLim', [min(exp.(epoch).eeg_ts(ind)) max(exp.(epoch).eeg_ts(ind))]);
            set(a(i), 'XTick', [], 'YTick', [], 'Box', 'off');
            %wb(i) = wave_browser(exp.(epoch).eeg(i).data(ind), exp.(epoch).eeg_ts(ind), a(i)); 
            
        end
      
        linkaxes(a, 'x');
        update_colors();
    end

    function epoch_changed(varargin)
       epoch = exp.epochs{get(epoch_sel_ui, 'Value')};
       clear a;
       clear wb;
       create_plots();  
    end
    function my_load(varargin)
        path = fullfile(exp.session_dir, 'valid_eeg_chans.mat');
        if exist(path, 'file');
            d = load(path);
            if length(valid_chan)==length(d.valid_chan)
                valid_chan = d.valid_chan;
                update_colors();
            else
                disp('Number of channels in file and evaluater are different');
                set(load_btn, 'Enable', 'off');
            end
       
        end
    end
            
    function my_save(varargin)
        path = fullfile(exp.session_dir, 'valid_eeg_chans.mat');
        answer = 'Yes';
        if exist(path)
            answer = questdlg('File Exist overwrite?');
        end
        if strcmp('Yes', answer);
            save(path, 'valid_chan');
            disp(['Saved: ', path]);
        end
    end
    function my_close(varargin)
        if ~exist(fullfile(exp.session_dir, 'valid_eeg_chans.mat'))
            answer = questdlg('File does not exist! Save it?');
            if strcmp(answer, 'Yes')
                 save(fullfile(exp.session_dir, 'valid_eeg_chans.mat'), 'valid_chan');
                 disp(['Saved: ', path]);
            end
        end
        hold_force = 0;
        delete(f);
    end
end


function sigs = load_signals(ses)
    if ~exist(fullfile(ses, 'sources.mat'),'file')
        f = define_sources(ses);
        waitfor(f);
    end
    d = load(fullfile(ses, 'sources.mat'));
    sigs = d.sources;
end