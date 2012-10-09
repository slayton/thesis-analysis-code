function [eeg eeg_ts]=load_eeg(session_dir, epoch_name, varargin)
%LOAD_EEG creates a struct containing eeg data from specified session and
%epoch
%
% eeg = LOAD_EEG(session_dir, epoch_name) 
% eeg = LOAD_EEG( ... , 'n_chan', number_of_channels) only loads the
% specified number of channels


args.n_chan = -1;

args = parseArgs(varargin, args);

data_dir = fullfile(session_dir, 'epochs', epoch_name);
eeg_files = get_dir_names(fullfile(data_dir, '*.eeg'));

[en et] = load_epochs(fullfile(session_dir, 'epochs'));
et = et(ismember(en, epoch_name),:);

fc = 0; %file count
if args.n_chan == -1
    arsg.n_chan = length(eeg_files);
end
args.n_chan;
length(eeg_files);
for i=1:length(eeg_files)
    ef = eeg_files{i};
    for ch=1:8
        fc = fc+1;
        %disp('NOT WRITTIN EEG ISNT LOADED');cd
        %eeg(i).file = fullfile;
        %file = files(ismember

        eeg(fc).file = fullfile(session_dir, 'epochs', epoch_name, ef);
        eeg(fc).raw_ad_file = fullfile(session_dir, 'extracted_data', ef);
        eeg(fc).name = [ef(1:end-4),'.ch' num2str(ch)];
        eeg(fc).channel = ch;
        disp([epoch_name, ': Loading: ', eeg(fc).file, ' channel ' , num2str(ch)]); 
        
        eeg(fc).gain = load_eeg_gains(eeg(fc).file, ch);
        ch_str = ['channel', num2str(ch)];
        dataIn = load(mwlopen(eeg(fc).file), {'timestamp', ch_str});
        eeg(fc).data = single(ad2mv(dataIn.(ch_str), eeg(fc).gain));
        eeg(fc).data(isnan(eeg(fc).data)) = 0;
        eeg(fc).data(isinf(eeg(fc).data)) = 0;
        eeg(fc).fs = 1.0/mean(diff(dataIn.timestamp));
        first_ts = dataIn.timestamp(1);
        eeg(fc).load_window = @(varargin) load_time_window(eeg(fc).data, first_ts, eeg(fc).fs, varargin{:});
        if fc==args.n_chan
            break
        end
    end
    if fc == args.n_chan
        break;
    end
end

eeg_ts = single( (1:length(eeg(1).data))./eeg(1).fs + first_ts);

valid_ts = eeg_ts>et(1) & eeg_ts<et(2);

for i=1:length(eeg)
    eeg(i).data = eeg(i).data(valid_ts);
end
eeg_ts = eeg_ts(valid_ts);

clear dataIn;


%% Assign tetrode name and location to each eeg signal
if exist(fullfile(session_dir, 'sources_and_signals.mat'), 'file');
    dataIn = load(fullfile(session_dir, 'sources_and_signals.mat'));
    sources = dataIn.sources_and_signals;
    
    for i=1:length(eeg)
        ind = cellfun(@strcmp, sources(:,1), repmat({eeg(i).name}, size(sources(:,1))));
        eeg(i).electrode = sources{ind,2};
        eeg(i).location = sources{ind, 3};
    end
end;


function [signal times] =  load_time_window(data, first_ts, fs, varargin)
    if numel(varargin)==0
        signal = data;
        times = (length(data)*fs)+first_ts;
        return
    end
    lims = varargin{1};
    tstart = lims(1);
    tend = lims(2);
    times = (1:length(data)).*1/fs + first_ts;
    ind = tstart <= times & times <=tend;
    times = times(ind);
    signal = data(ind);
end

end