function [eeg times fs] = load_raw_eeg(varargin)
% [eeg times fs] = load_raw_eeg(file_name,channel tstart, tend) loads the raw eeg data from the 
% specified file
% [eeg times fs] = load_raw_eeg(mwleegobject, gain, channel tstart tend)

if numel(varargin)==4
    
    channel = varargin{2};
    if ~isnumeric(channel)
        error('channel must be numeric');
    elseif channel<1 || channel>8
        error('channel must be between 1-8');
    end
    
    file = varargin{1};
    if ~isa(file,'char')
        error('File must be a string');
    end
    if exist(file)
        f = mwlopen(file);
        if ~isa(f, 'mwleegfile')
            error(['load_raw_eeg: File ', file, ' is not a valid mwl eeg file.']);
        end
        gain = load_eeg_gains(file, ['channel',num2str(channel)],2);
    else
        error('File does not exist');
    end
        
    tstart = varargin{3};
    if ~isnumeric(tstart)
        error('tstart must be numeric');
    end
    
    tend = varargin{4};
    if ~isnumeric(tend)
        error('tend must be numeric');
    end
    
elseif numel(varargin)==5
    f = varargin{1};
    if ~isa(f, 'mwleegfile')
        error('Must specify a valid mwleegfile or file');
    end
    gain = varargin{2};
    if ~isnumeric(gain)
        error('gain must be numeric');
    end
    channel = varargin{3};
    if ~isnumeric(channel)
        error('channel must be numeric');
    elseif channel<1 || channel>8
        error('channel must be between 1-8');
    end
    tstart = varargin{4};
    if ~isnumeric(tstart)
        error('tstart must be numeric');
    end
    tend = varargin{5};
    if ~isnumeric(tend)
        error('tend must be numeric');
    end
end
    
buffer_inds = calculate_indecies(f, [tstart, tend]); % 

data = load(f, {'timestamp', 'data'}, buffer_inds(1):buffer_inds(2));

%disp(['NBuffers: ', num2str(length(buffer_inds(1):buffer_inds(2)))]);
s = size(data.data(channel,:,:)); 

un_buffered_data = reshape(data.data(channel,:,:), s(1).*s(2).*s(3),1);

dt = single((data.timestamp(2) - data.timestamp(1)))/10000; % delta t between buffers

dt_samp = dt/s(2); % delta t between actual samples

timestamps = (1:length(un_buffered_data))*dt_samp+single(data.timestamp(1))/10000;

ind = timestamps>=tstart & timestamps<=tend;

eeg = un_buffered_data(ind);

gain = repmat(gain, size(eeg));

eeg = ad2mv(eeg, gain);
times = timestamps(ind);

fs = 1/mean(gradient(times));

end

function inds = calculate_indecies(f, range)
   
    d = load(f, {'timestamp'}, 1:2);
    ts = single(d.timestamp(1))/10000;
    dt = single(d.timestamp(2)-d.timestamp(1))/10000;
    
    inds(1) = floor((range(1)-ts)/dt) ;
    inds(2) = ceil((range(2)-range(1))/dt) + inds(1)+2;

end
