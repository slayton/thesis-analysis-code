function mu=load_multiunit(session_dir, epoch_name)
% LOAD_MULTIUNIT(session_dir, epoch_name)
% loads the timestamps of all threshold crossing from all tt files
% contained in session_dir/extracted_data

fields = {'timestamp', 'waveform'};
[e_name e_times] = load_epochs(fullfile(session_dir, 'epochs'));
e_ind = find(strcmp(e_name, epoch_name));
epoch_range = e_times(e_ind,:)*10000;

t_start = e_times(e_ind,1);
t_end = e_times(e_ind,2);


tt_files = get_dir_names(fullfile(session_dir, 'extracted_data', '*.tt'));
multi_unit = [];
for i =1:length(tt_files)
    disp([epoch_name, ': Loading multi-unit from: ' tt_files{i}]);
    file = fullfile(session_dir, 'extracted_data', tt_files{i});
    times = get_spike_times(file);
    multi_unit = [multi_unit, times];
end

multi_unit = sort(multi_unit);
mu = single(multi_unit);
%mu.info = fullfile(session_dir, epoch_name);
disp(['Multi-unit loaded from :', num2str(i), ' tetrodes!']);
        
function times = get_spike_times(file)
    thold = 100;  % 100 millivolts;
    d = dir(file);
    
    if d.bytes>15*1024^2
        f = loadrange(mwlopen(file), fields, epoch_range, 'timestamp');
        warning off;
        ind = f.timestamp<=uint32(t_end*10000) & f.timestamp>=uint32(t_start*10000);
        warning on;
        f.timestamp = f.timestamp(ind);
        f.waveform = f.waveform(:,:,ind);

        gains = get_gains(file);

        maxes = max(f.waveform, [], 2);
        maxes = reshape(maxes, 4, length(maxes), 1);
        gains = repmat(gains, length(maxes),1);
        nano_volts = max(double(maxes)/4096.0 * 10 ./gains' * 1e6);

        %min(nano_volts)
        times = double(f.timestamp(nano_volts>=thold))/10000;    
    else
        times = [];
    end
end

    function gains = get_gains(file)
       
        head = loadheader(file);

        chans = [0 1 2 3];
        if head(1).Probe
            chans = chans+4;
        end

        strA = 'channel ';
        strB = ' ampgain';
        gains = nan(1,4);
        for j=1:length(chans);
            str(j,:) = [strA, num2str(chans(j)), strB];
            gains(j) = str2double(head(2).(str(j,:)));
        end
    end        
end