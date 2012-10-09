
% Create a struct called plot me that contains rasters for each cell in
% Order Midazolam struct
% DEFINITIONS FOR SCRIPT
con.start = 7106.35;
con.end = 7800.55;
con.cells = orderControl;
con.eeg = eegRawControl;
con.eegChan = 3;

drug.start = 7800.55;
drug.end = 9395.25;
drug.cells = orderMidazolam
drug.eeg = eegRawDrug;
drug.eegChan = 3;

epoch.start = epochRunDrugSleep(1);
epoch.end = epochRunDrugSleep(2);
epoch.eegChan=3;
epoch.eeg = eeg;
epoch.eeg.data = epoch.eeg.data(:,epoch.eegChan);
epoch.eeg = contwin(epoch.eeg, [epoch.start epoch.end]);
epoch.eeg = contresamp(epoch.eeg, 'resample', 1500/epoch.eeg.samplerate);
epoch.cells = orderRDS;
p =position;

%
% ----------------------------- ORDER PLACE CLELS
%

clear plotMe;
for cell=1:length(epoch.cells)
    t = ones(length(epoch.cells(cell).id)*3,1);
    for i=1:length(t); t(i) = NaN; end;
    T = t; %Array of times
    Y = t; %Array of Y Values
    for spike=1:length(T)
        if mod(spike,3) == 1
            Y(spike) = cell;
            T(spike)=epoch.cells(cell).times(floor((spike-1)/3)+1);
       end;
       if mod(spike,3) == 2
         Y(spike) = cell-1;
         T(spike)=epoch.cells(cell).times(floor((spike-1)/3)+1);
       end;
       if mod(spike,3) == 3
           Y(spike) = NaN;
           T(spike) = NaN;
       end;
    end
    plotMe(cell).T = T; %Save the cell specific array to that cell
    plotMe(cell).Y = Y;
end;

%
% - PLOT SPIKES IN RASTER!------------------------------------
%
figure;
for cell=1:length(plotMe)
     hold on;subplot(3,1,1); plot(plotMe(cell).T, plotMe(cell).Y);
end;

%
% ---------------- COMPUTE POSITION INFORMATION -------------------
%

times = computeTimeIndecies(p.timestamp, epoch.start, epoch.end);
timeIndex = times.start:times.end;

pos.x = p.xfront(timeIndex);
pos.y = p.yfront(timeIndex);
badPos = (pos.x<-125 | pos.y<20);

pos.x(badPos) = NaN;
pos.y(badPos) = NaN;

pos.x = pos.x - mean(pos.x);
pos.y = pos.y - mean(pos.y);

pos.times = double(position.timestamp(timeIndex));
pos.times(badPos) = NaN;

[pos.h pos.phi] = linearizePosition(pos.x, pos.y, 'circle');
pos.p = pos.phi * mean(pos.h);

pos.x = p.xfront(timeIndex);
pos.y = p.yfront(timeIndex);
badPos = (pos.x<-125 | pos.y<20);

pos.unWrap = unwrap(pos.phi);
pos.vel = gradient(pos.unWrap);
pos.smoothVel = smoothn(pos.vel,20);

threshold = mean(pos.smoothVel);
pos.logicalVel = zeros(length(pos.smoothVel),1);
removeMe = abs(pos.smoothVel)>threshold;
pos.logicalVel(removeMe) = NaN;

stop_times = logical2seg(pos.times, pos.logicalVel); %[start stop] for each time the animal stops moving

pos.tPlot = pos.times/10000;

%
% ------------ PLOT POSITION INFORMATION
%
subplot(3,1,3); plot(pos.tPlot, pos.unWrap/1500,pos.tPlot, pos.smoothVel,'r', pos.tPlot, pos.logicalVel,'g.' );

%
% ------------ Computer EEG Information
%

ripples.ripples = filterRipple(epoch.eeg.data, epoch.eeg.samplerate);
ripples.amp = abs(hilbert(ripples.ripples));
ripples.amp = smoothn( ripples.amp, 0.0125, epoch.eeg.samplerate);

ripples.timestamps = 1:length(ripples.ripples);
ripples.timestamps = ripples.timestamps';
scaler = length(ripples.ripples)/(epoch.eeg.tend-epoch.eeg.tstart);
ripples.timestamps = (ripples.timestamps/scaler) + epoch.start;


ii = inseg( stop_times, ripples.timestamps);
ripples.mean = mean( ripples.amp(ii));
ripples.std = std( ripples.amp(ii));
ripples.thold = ripples.mean+ripples.std*3;

peak_idx  = find( localmaximum(ripples.amp));

peak_idx = peak_idx( inseg( stop_times, ripples.timestamps (peak_idx) ) & ripples.amp( peak_idx)>ripples.thold);
peak_times = ripples.timestamps(peak_idx);
peak_amp = ripples.amp(peak_idx);




%Define Xaxis for EEG, then Plot the EEG signal

subplot(3,1,2); plot(ripples.timestamps, epoch.eeg.data, ripples.timestamps, ripples.ripples*3,'g');

linkaxes( get(gcf, 'children'), 'x')

