% Analysis Steps
% 1- Load Data
%   a - Load Data
%   b - Filter Data
%   c- Select subset of Data 
%       1- Run
%       2- Stop
%   d- Compute Power
% 2- Compute the bootstrapped confidence bound
%
% 3- Compare the different distributions


%% 0 - Globals

d_type = {'real', 'fake'};
states = {'run', 'stop'};
epochs = {'control', 'midazolam'};
bands = {'slow', 'theta', 'beta', 'gamma', 'ripple'};
power_type = {'square', 'hilbert'};
e_ch = 3;
time_win = 20; % use 20 seconds of data
min_time_win = .5;
run_thold = .10; %10 cm/second
stop_thold = .04; % 4 cm/second
%% Data Source
data_source = gh;
%% 1a - Load the data
clear data ep e st s ba b data_source_run data_source_stop eeg eeg_run eeg_stop eeg_run_ts ind_data;

disp('- Loading Data');
type = d_type{1}; %%%%% Load Real Data

for ep = epochs
    e = ep{:};    
    disp(['Epoch:', e]);
    disp('  Loading RAW data');
   
    data.(e).raw = data_source.(e).eeg(e_ch).data;
    data.(e).ts = data_source.(e).eeg_ts;  % why do I care about the timestamps?
    data.(e).fs = data_source.(e).eeg(e_ch).fs;
    n_samp = floor(data.(e).fs * time_win);
end
disp('DONE Loading Data ');disp(' ');
%%  1b - Calculate run/stop indecies
clear ind ind1 ind2 ind_data; 
disp('- Calculating Run/Stop indecies');
for ep = epochs
    e = ep{:};
    disp(['Epoch:', e]);

    for st = states
        s = st{:};
        disp(['   State:', s]);
        

        switch s
            case 'run'
                ind_data.(e).(s).times = find_run_times(data_source.(e).position.lin_vel, data_source.(e).position.timestamp);
            case 'stop'
                ind_data.(e).(s).times = find_stop_times(data_source.(e).position.lin_vel, data_source.(e).position.timestamp);
        end
        % only select bouts over 1/2 second long
        ind_data.(e).(s).times = ind_data.(e).(s).times(diff(ind_data.(e).(s).times,1,2)>min_time_win,:);
        ind_data.(e).(s).ind = nearestpoint(ind_data.(e).(s).times, data_source.(e).eeg_ts(:));
        ind1 = [];
        ind2 = [];
        for i=1:length(ind_data.(e).(s).ind)
            ind1 = ind_data.(e).(s).ind(i,1):ind_data.(e).(s).ind(i,2);
            ind2 = [ind2; ind1(:)]; %#ok
        end
        ind_data.(e).(s).ind = ind2;        
        
        ind_data.(e).(s).rand_samp = randsample(ind_data.(e).(s).ind, n_samp);
    end
end
disp('DONE Calculating Run/Stop Indecies'); disp(' ');
%% 2 - Do the filtering
clear ep e ba b f;

disp('Filtering Data');
for ep=epochs
    e = ep{:};
    disp(['Epoch:', e]);   
    for ba = bands
        b = ba{:}; 
        disp(['   Filtering: ', b, '...']);

        f = getfilter(data.(e).fs,b, 'win');
        data.(e).(b).raw = filtfilt(f,1,data.(e).raw); % filter all of the data
    end
end
disp('DONE Filtering Data');disp(' ');
%% 3 - Compute Power
%{
clear ep e ba b st s pt p temp_data;
disp('- COMPUTING POWER ');
for ep = epochs
    e = ep{:};
    disp(['Epoch:', e]);
    for ba = bands
        b = ba{:};
        disp(['  Band: ', b,' ...']);
        for st = states
            s = st{:};
            disp(['      State: ', s,' ...']);
            for pt = power_type
                p = pt{:};
                disp(['        Power Type: ',p]);
                switch p
                    case 'square'
                        temp_data = data.(e).(b).raw.^2;
                    case 'hilbert'
                        temp_data = abs(hilbert(data.(e).(b).raw));
                end
            data.(e).(b).(s).(p) = temp_data();
%           data.(e).(s).([b,'_',p]) = temp_data(eeg.(s).rand_samp');
            end
        end
    end
end
%}
%% 4 - Select START STOP TIMES
clear ep e ba b st s pt p temp_data;
disp('- Downsampling Power by Run/Stop Time');
for ep = epochs
    e = ep{:};
    disp(['Epoch:', e]);
    for ba = bands
        b = ba{:};
        disp(['  Band: ', b,' ...']);
        for st = states
            s = st{:};
            disp(['      State: ', s,' ...']);
            for pt = power_type
                p = pt{:};
                disp(['        Power Type: ',p]);
                data.(e).(b).(s) = data.(e).(b).raw(ind_data.(e).(s).rand_samp);
            end
        end
    end
end
disp('DONE Downsampling power'); disp(' ');

%% QQ Plots
n_plot =0;
for st = states
    s = st{:};
    for ba = bands
        b = ba{:};
        n_plot = n_plot+1;

        subplot(numel(bands),numel(states), n_plot);
        qqplot(data.(epochs{1}).(b).(s), data.(epochs{2}).(b).(s));
        title([b, ' ', s, ' ',epochs{1}, ' vs ', epochs{2}]);
    end
end

%%

    %{
    for st = states
            s = st{:};
            data.(e).(s).raw = data.(e).raw(eeg.(s).rand_samp); 
            data.(e).(s).ts = data.(e).ts(eeg.(s).rand_samp);
    end

    data.(e) = rmfield(data.(e), {'raw', 'ts'});
    %}
%% Old Analysis Code
%{
%% 2 - Compute the Bootstrap
clear stats ep e st s ba b nboot;
nboot = 2000;
disp('------------------- Computing Bootstrap -------------------');
for ep = epochs
    e = ep{:};
    disp(['Epoch: ', e]);
    
    for st = states
        s = st{:};
        disp(['   State: ', s]);
        
        for ba = bands
            b = ba{:};
            for pt = power_type
                p = pt{:};
                disp(['      Computing Bootstrap: ', b, '  power type:', p]);
                stats.(e).(s).(b).(p).std = bootstrp(nboot, @std, data.(e).(b).(s).(p));
            end
        end
    end
end
disp('Done computing bootstap');


%% 3 - Plot Bootstraps
clear ep e i ba b j st s k hdat c bins;

colors = {'r', 'r'; 'k', 'k'};  
line_style={'-', '-'; '-', '-'};
line_w = [3, 1; 3, 1];
ind1=0;
figure('Name', ['PType:', p, ' ECh:', num2str(e_ch), ' ',  data_source.session_dir],...
    'Position', [500 100 1000 1000]);
sub_ind(:,1) = repmat(numel(bands),numel(bands)*numel(power_type),1);
sub_ind(:,2)= repmat(numel(power_type), numel(bands)*numel(power_type),1);
sub_ind(:,3) = ([1:2:numel(bands)*numel(power_type) 2:2:numel(bands)*numel(power_type)])';

    
p_count =0;
for pt = power_type
    p = pt{:};
    i=0;
    
    for ba = bands
        b = ba{:};
        i = i+1;
        p_count = p_count+1;
        ind2 = ind2+1;
        j = 0;
        sub_ind(i,:)
        subplot(sub_ind(p_count,1), sub_ind(p_count,2), sub_ind(p_count,3));
        for ep = epochs
            e = ep{:};
            j = j+1;     
            k = 0;
            for st = states
                s = st{:};
                k = k+1;
                h_dat = stats.(e).(s).(b).(p).std;

                bins = min(h_dat):(max(h_dat)-min(h_dat))/100:max(h_dat);

                h_dat = histc(h_dat, bins);   

                style = [line_style{j,k} colors{j,k}];
                %disp([c, ' ',  epochs{j} , ' ', states{k}]);
                plot(bins, h_dat, style, 'LineWidth', line_w(j,k)); hold on;                     
            end
            title([b, ' ', p])

        end
        hold off;    
    end

end
    legend('Con-Run', 'Con-Stop', 'Mid-Run', 'Mid-Stop');

    
%% Plot raw Distributions
clear ep e i ba b j st s k hdat c bins;

colors = {'r', 'r'; 'k', 'k'};  
line_style={'-', '-'; '-', '-'};
line_w = [3, 1; 3, 1];
ind1=0;
b_old = bands;
%bands = {'theta', 'beta', 'gamma', 'ripple'};
figure('Name', [' ECh:', num2str(e_ch), ' ',  data_source.session_dir],...
    'Position', [500 100 1000 1000], 'NumberTitle', 'off');

sub_ind = [321, 322, 323, 324, 325, 326];
    
p_count =0;
for pt = {'square'}
    p = pt{:};
    i=0;
    
    for ba = bands
        b = ba{:};
        i = i+1;
        p_count = p_count+1;
        ind2 = ind2+1;
        j = 0;
        %sub_ind(i,:);
        subplot(sub_ind(p_count));
        for ep = epochs
            e = ep{:};
            j = j+1;     
            k = 0;
            for st = states
                s = st{:};
                k = k+1;
                
                h_dat = data.(e).(b).(s).(p);

                bins = 0:.01:20;

                hist_dat = smoothn(histc(h_dat, bins),10, 'correct', 1);   

                style = [line_style{j,k} colors{j,k}];
                %disp([c, ' ',  epochs{j} , ' ', states{k}]);
                plot(bins, hist_dat, style, 'LineWidth', line_w(j,k)); hold on;                     
            end
            set(gca, 'XLim', [0 1.5]);
            title([b, ' ', p])

        end
        hold off;    
    end

end
    legend('Con-Run', 'Con-Stop', 'Mid-Run', 'Mid-Stop');
bands = b_old;
%}