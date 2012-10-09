



cdat = eegRippleCont;
channel = 1;
eeg = cdat.data(:,channel);

eegPow = eeg.*eeg;

cdatMine = cdat;
cdatMine.data = eegPow;
cdatMine.datarange = [min(eegPow) max(eegPow)];

cdatLow = filterLow(cdatMine);
cdatLow.xaxis = tstart:(1.0/cdatLow.samplerate):tend;
cdatLow.thold = mean(cdatLow.data) + 2.5 * std(cdatLow.data);
cdatLow.tholded = cdatLow.data .* (cdatLow.data>cdatLow.thold);
% Correct cdatLow.xaxis
if length(cdatLow.xaxis)+1 == length(cdatLow.data(:,1))
    cdatLow.xaxis(length(cdatLow.xaxis)+1) = cdatLow.xaxis(length(cdatLow.xaxis+(1.0/cdatLow.samplerate)));
    disp ('Correcting yaxis length');
end;

h  = abs(hilbert(cdatLow.data)); % hilbert transform of signal
%h = h.*conj(h); % hilbert has both real and imaginary so remove the imaginary component
hbar = mean(h);
hsigma = std(h);
h_threshold = hsigma*4.5;
h_thresholded = (h>h_threshold) .* h;

freq = 1.0/cdat.samplerate;
tstart = cdat.tstart;
tend = cdat.tend;
xaxis = tstart:freq:tend;
if length(xaxis)+1 == length(cdat.data(:,1))
    xaxis(length(xaxis)+1) = xaxis(length(xaxis+freq));
    disp ('Correcting yaxis length');
end;

figure; subplot(2,1,1); plot(xaxis', eeg,   cdatLow.xaxis, cdatLow.data,'g',     cdatLow.xaxis, cdatLow.tholded, 'r');    subplot(2,1,2); plot(cdatLow.xaxis', h, cdatLow.xaxis', h_thresholded,'r');
linkaxes( get(gcf, 'children'), 'x')