
clear;

% e = exp_load_run('/data/spl11/day11');
e = exp_load_run('/data/spl11/day10');
e = process_loaded_exp2(e, [2 4]);

% %% Specific Code for loading SPL11-D12
% e = exp_load('/data/spl11/day12', 'epochs', 'run2', 'data_types', {'clusters', 'pos'});
% e = process_loaded_exp2(e, [1 2 4 7]);
% e.run = e.run2;
% e = rmfield(e, 'run2');


%%
clear b lIdx rIdx eLeft eRight rLeft rRight

b = e.run.mu.bursts;

lIdx = strcmp( {e.run.cl.loc}, 'lCA1');
rIdx = strcmp( {e.run.cl.loc}, 'rCA1');

[eLeft, eRight] = deal(e);
eLeft.run.cl = eLeft.run.cl(lIdx);
eRight.run.cl = eRight.run.cl(rIdx);8

rLeft = exp_reconstruct(eLeft, 'run', 'tau', .02, 'directional', 0);
rRight = exp_reconstruct(eRight, 'run', 'tau', .02, 'directional', 0);

rRun = exp_reconstruct(e, 'run','directional', 0);
%%
% Potential spl11-d10 replay events: 
% Potential spl11-d11 replay events: 14-, 41, 42, 59, 65, 68, 72-, 120
% Potential spl11-d12 replay events: 21, 31++, 41, 49++, 54++, 77, 117
% Potential spl11-d13 replay events: 38-, 40, 96, 130, 131+, 139++
% Potential spl11-d14 replay events: 124++ 
% Potential spl11-d15 replay events: NONE
clear tb pb p1 p2;

tb = rLeft.tbins;
pb = rLeft.pbins;
p1 = rLeft.pdf(:,:,1);
p2 = rRight.pdf(:,:,1);
p3 = rRun.pdf(:,:,1);

close all;
figure;
ax(1) = axes('Position', [.05 .67 .9 .30]);
imagesc(tb, pb, 1 - repmat(p1, [1 1 3]), 'Parent', ax(1));
ax(2) = axes('Position', [.05 .34 .9 .3]);
imagesc(tb, pb, 1 - repmat(p2, [1 1 3]), 'Parent', ax(2));
ax(3) = axes('Position', [.05 .01 .9 .3]);
imagesc(rRun.tbins, rRun.pbins, 1 - repmat(p3, [1 1 3]));
line(e.run.pos.ts, e.run.pos.lp, 'color', 'r');


for i = 1:size(b,1)
    title(ax(1), sprintf('%d', i));
    set(ax,'XLim', mean(b(i,:)) + [-.2 .2])
    pause;
    
end