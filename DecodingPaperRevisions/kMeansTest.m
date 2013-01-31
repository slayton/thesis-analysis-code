%% Load the data
clear
fid = mwlopen('/data/examples/s11d15.t08.f.pxyabw');

d = load(fid);
data = double( [d.t_px; d.t_py; d.t_pa; d.t_pb] );
% data = [data];


thold = quantile( data(:), .9999) * 2;

validIdx  = max(data) < thold & min(data) > 0;
data = data(:, validIdx)';

amp = data;
% amp = data(1:4000, :);

%%

[clId, clPos] = kmeans(amp, 25, 'MaxIter', 500);

%%
nClust = numel( unique(clId) );

close all; figure; 
cmap = colormap('jet');
cmap = interp1(1:size(cmap,1), cmap, linspace(1, size(cmap,1), nClust) );

for i = 1:nClust
   idx = clId == i;
   line(amp(idx,1), amp(idx,2), amp(idx,4), 'marker','.', 'linestyle', 'none', 'color', cmap(i,:) );
end

lim = [0 thold/2];
set(gca,'XLim', lim, 'YLim', lim, 'Zlim', lim);