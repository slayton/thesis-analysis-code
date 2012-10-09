classdef cell_source < data_source
    properties (Access=public)
        data_file = []; 

    end
    properties (SetAccess=private, GetAccess=public)
        source = [];
        location = [];
        waveform = [];
    end
    properties (Access=private)
       fields = {'time', 'id'};
        times = [];
    end
    
    methods
        function obj = cell_source(data_file, varargin)
            obj.data_file = data_file;
        end      
%%%%% GET
        function wave = get.waveform(obj)
            disp('not sure why this is not saving state, deal with it when you need it');
            if isempty(obj.waveform)
                disp('Need to load waveforms');
                obj = obj.load_waveforms();
            end
            wave = obj.waveform;
            isempty(obj.waveform)
        end
        
%%%%% SET
        function obj = set.data_file(obj, value)
            if ~exist(value,'file')
                error('No Such file');
            end
           obj.data_file = value; 
           obj = new_file_set(obj);
        end    
%%%%% cell_source specific fields
        
%%%%% DATA_SOURCEh
        
        function data = get_data(obj, varargin)
            if isempty(varargin)
                disp('No times specified, loading all times');
                data = obj.times;
            else
                t = varargin{1};
                if length(t)~=2
                    error('get_data(t), t must be vector length 2');
                end
                data = obj.times(obj.times>=(1) & obj.times<=t(2));
            end
        end
        
        function source = get_source(obj)
            source = obj.source;
        end
        function random(obj)
        disp(obj.location)
        disp(obj.source)
        end
    end
    methods (Access=protected)
       
        function obj = new_file_set(obj)
            f = mwlopen(obj.data_file);
            data = load(f, obj.fields);
            obj.times = data.time;
            base_dir = fileparts(fileparts(fileparts(fileparts(obj.data_file))));
            [garbarge tt_id] = fileparts(fileparts(obj.data_file));
            [obj.source obj.location] = load_source(base_dir, tt_id);
        end
        
        function obj = load_waveforms(obj)
            data = load(mwlopen(obj.data_file), 'id');
            id = data.id;
          
            tt_dir = fileparts(obj.data_file);
            [path tt_id] = fileparts(tt_dir);
            tt_file = fullfile(tt_dir, [tt_id, '.tt']);
            data = load(mwlopen(tt_file), 'waveform', id);
            obj.waveform = mean(data.waveform,3);
            gains = repmat(load_gains(tt_file),1, length(obj.waveform));
            obj.waveform = ad2mv(obj.waveform, gains)';
        end
    end
end
