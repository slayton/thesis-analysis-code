
session_dir = '/home/slayton/data/disk1/fab/fk18/day07';
epoch = 'run1';

c = load_clusters(session_dir, epoch);  %#ok or load from disk
pos = load_position(session_dir, epoch); % or load from disk
c_bkp =c;
c = new_c;

%%%%%%%%%%%% Calculate Curves %%%%%%%%%%%%%%
warning('off');
for i=1:length(c)
    [c(i).field1 c(i).field2] = calculate_place_field(c(i).time, pos.linear_position, pos.timestamp, pos.linear_direction, 1.0/30.0);
end;     
warning('on');

%%%%%%%%%%%%%% Plot Curves %%%%%%%%%%%%%%%%%%%
plot_me = 0;
if plot_me
    for i=1:length(c) %#ok
        field1 = max(c(1).field1)>0;
        field2 = max(c(1).field2)>0;

        if field1 || field2
            figure;
        end;
        if field1
            h = area(c(i).field1); hold on;
            set(h, 'FaceColor', 'r');
            set(h, 'EdgeColor', 'r');
            set(gca, 'Title', title(num2str(i)));
        end;
        if field2
            h = area(-c(i).field2);
            set(h, 'FaceColor', 'b');
            set(h, 'EdgeColor', 'b'); hold off;
        end
    end 
end

%%%%%%%%%%%%%% Calculate Stopping %%%%%%%%%%%%%%%%%%%
stop_ind = calculate_velocity(pos.linear_position, 0 , .25, 1/30)<.05;
stop_times = pos.timestamp(stop_ind);

%%%%%%%%%%%%%% Load EEG Signal %%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%% Load Multi-Unit %%%%%%%%%%%%%%%%%%%%%%

%multi_unit = load_multiunit(session_dir, epoch);






%%%%%%%%%%% Prepare for Param Estimation
c = clusters2; 
pos = pos2;

warning off;
tau = .2;  %%  <---- Define tau

field_len = length(c(1).field1)*2;
tuning_curves = nan(1, field_len);
time_bins = min(pos.timestamp):tau:max(pos.timestamp);
n_spikes = zeros(length(c), length(time_bins));
for i=1:length(c)
    tuning_curves(i,:) = [c(i).field1 ];%c(i).field2];
    n_spikes(i,:) = hist(c(i).time, time_bins);
end;

pdf = zeros(field_len/2, length(time_bins),2);
pdf2 = zeros(field_len/2, 2,length(time_bins));
for i=1:length(time_bins)
    a = reconstruct_bayesian_poisson(tuning_curves', n_spikes(:,i), 'bins', length(time_bins));
    pdf2(:,:,i) = a;
    if mod(i,1000)==0
        disp(i);
    end
end;

    
ts = pos.timestamp(1);
te = pos.timestamp(end);

pos_xaxis = pos.timestamp;
%img_yaxis = 1:size(pdf, 1);
%scale_factor = length(pos.timestamp)/size(pdf,2);
%img_xaxis = pos_xaxis(1):scale_factor:pos_xaxis(end);
img_xaxis = generate_timestamps(pos.timestamp(1), pos.timestamp(end), size(pdf,2));
img_yaxis = 1:size(pdf,1);


figure; imagesc(img_xaxis, img_yaxis, pdf(:,:,1)); colormap(gca(), 'Hot');
colormap(gca, 'hot'); set(gca, 'YDir', 'normal'); hold on; 
plot(pos_xaxis, pos.linear_position*10, '--b','LineWidth', .5); 
pan('xon');
zoom('xon');
warning on;