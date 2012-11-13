
%  Using data from generateFigure3_2B.m

idx = (376:751);
x = 1:numel(idx);
y = meanMuaSleep(idx);
x = x - x(1);
y = y - min(y) + .0000001;
y = y ./ max(y);

Fs = 1500;
z = log(y);

P = polyfit(x, z,1);

yHat = exp( x*P(1) + P(2) );
yHat = yHat / max(yHat);




yDiff = y - yHat;

[~, peakLocs] = findpeaks( yDiff );


peakTimes = peakLocs / ripples.Fs;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        PLOT THE RESULTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;

subplot(4,1,1:3);

plot(x / Fs, y); hold on;
plot(x / Fs, yHat,'r' );
line(x(peakLocs) / Fs, y(peakLocs), 'color', 'r', 'Marker', '.', 'linestyle', 'none', 'markersize', 20);
xlabel('Time');
ylabel('MU Rate');
title('Ripple Triggered MUA');

legend({'Data', 'ExpModel'});
subplot(414);
plot(x/Fs, yDiff, 'g');


line(x(peakLocs) / Fs, yDiff(peakLocs), 'color', 'r', 'Marker', '.', 'linestyle', 'none', 'markersize', 20);

saveFigure(gcf,'/home/slayton/Desktop/', 'ripple_beta');