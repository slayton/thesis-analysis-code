fs = 1;
t = -3:1/fs:3;

F = 2;
A = 1.75;
y = A*sin(2*pi .* t * F );

close all;
figure; axes('NextPlot', 'add');
line(t,y,'color', 'b', 'Marker','.', 'markersize', 20);

h = hilbert(y);

line(t, abs(h), 'color', 'r');
line(t, angle(h), 'color',  'g');
line(t, ( fs * gradient( unwrap( angle(h) ) ) ) ./ (2*pi), 'Color', 'c');
