%% Load the data
clear
velThold = .05;
ampThold = 125;
baseDir = '/data/examples';
baseFile = '/s11d15.t08';
epoch = 'run';

[en et] = load_epochs(baseDir);
et = et(strcmp( en, epoch),:);

pxyFile = sprintf('%s/%s.pxyabw', baseDir, baseFile);
ttFile =  sprintf('%s/%s.tt', baseDir, baseFile);
posFile = sprintf('%s/run.lin_pos.p', baseDir);

pxyFid = mwlopen(pxyFile);
ttFid = mwlopen(ttFile);
posFid = mwlopen(posFile);

ttHead = loadheader(ttFile);
probe = getFirstParam(ttHead,'Probe');

if probe==0
    gains = [...
        str2double( getFirstParam(ttHead,'channel 0 ampgain')); ...
        str2double( getFirstParam(ttHead,'channel 1 ampgain')); ...
        str2double( getFirstParam(ttHead,'channel 2 ampgain')); ...
        str2double( getFirstParam(ttHead,'channel 3 ampgain'))];
             
else
    gains = [...
        str2double( getFirstParam(ttHead,'channel 4 ampgain')); ...
        str2double( getFirstParam(ttHead,'channel 5 ampgain')); ...
        str2double( getFirstParam(ttHead,'channel 6 ampgain')); ...
        str2double( getFirstParam(ttHead,'channel 7 ampgain'))];
end

d = load(pxyFid);
data = [d.t_px; d.t_py; d.t_pa; d.t_pb];

p = load(posFid);
spikeVel = abs( interp1(p.timestamp, p.lv, d.time, 'nearest') );

epochIdx = d.time >= et(1) & d.time(2) <=et(2);
movingIdx = spikeVel >= .05;
ampIdx = min(data) >= ampThold;

idx = epochIdx & movingIdx & ampIdx;

data = data(:,idx);


%% Save a complete file
basePath = '/data/clustering/';

filename = [basePath, 'big.fet.1'];
fid = fopen(filename,'w+');
fprintf(fid, '4\n');
fprintf(fid, '%d\t%d\t%d\t%d\n', data);
fclose(fid);

filename = [basePath, 'small.fet.1'];
fid = fopen(filename,'w+');
fprintf(fid, '4\n');
fprintf(fid, '%d\t%d\t%d\t%d\n', data(:, 1:4000) );
fclose(fid);

%% Cluster the file file

fileBase = 'big';
cmd = ['~/src/clustering/kk2.0/KlustaKwik ', basePath, fileBase, ' 1'];
system(cmd);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            LOAD the clustered data from DISK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;

basePath = '/data/clustering/';
fileBase = 'big';

clId = dlmread([basePath, fileBase, '.clu.1']);
 
amp = importFeatureFile( [basePath, fileBase, '.fet.1']);

nClust = clId(1);

clId = clId(2:end);
%%
close all;
figure;
% plot3(amp(:, 1), amp(:, 2), amp(:,3), 'k.', 'markersize', 20);

cmap = colormap('jet');
cmap = interp1(1:size(cmap,1), cmap, linspace(1, size(cmap,1), nClust), 'nearest');

for i = 1:nClust
   idx = clId == i;
   line(amp(idx,1), amp(idx,2), amp(idx,4), 'marker','.', 'linestyle', 'none', 'color', cmap(i,:) );
end

lim = [0 1800];
set(gca,'XLim', lim, 'YLim', lim, 'Zlim', lim);
%%

figure('Position', [1000 266 630 800]); 
proj = 0;

c = 'rgbcmkrgbcmkrgbcmkrgbcmkrgbcmk';


for i = 2:5
    for j = i+1:5
        
        proj = proj+1;
        subplot(3,2,proj);
        
        for k = 1:nCl
            idx = pts(:,1)==k;
            line( pts(idx, i), pts(idx, j), 'marker', '.', 'linestyle', 'none', 'color', c(k));
        end
        
    end
end

%%

figure;

for k = 1:nCl
    idx = pts(:,1)==k;
    line( pts(idx, 2), pts(idx, 3), pts(idx,4), 'marker', '.', 'linestyle', 'none', 'color', c(k));
end





