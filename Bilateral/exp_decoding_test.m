
clear;

% e = exp_load_run('/data/spl11/day11');
e = exp_load_run('/data/spl11/day10');
e = process_loaded_exp2(e, [2 4]);

% %% Specific Code for loading SPL11-D12
% e = exp_load('/data/spl11/day12', 'epochs', 'run2', 'data_types', {'clusters', 'pos'});
% e = process_loaded_exp2(e, [1 2 4 7]);
% e.run = e.run2;
% e = rmfield(e, 'run2');

ep = 'sleep';

%%
clear b lIdx rIdx eLeft eRight rLeft rRight

b = e.(ep).mu.bursts;

lIdx = strcmp( {e.(ep).cl.loc}, 'lCA1');
rIdx = strcmp( {e.(ep).cl.loc}, 'rCA1');

[eLeft, eRight] = deal(e);
eLeft.(ep).cl = eLeft.(ep).cl(lIdx);
eRight.(ep).cl = eRight.(ep).cl(rIdx);

clear r
r(1) = exp_reconstruct(eLeft, ep, 'tau', .02, 'directional', 0);
r(2) = exp_reconstruct(eRight, ep, 'tau', .02, 'directional', 0);

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Potential RUN Replay Events
% spl11-d10 replay events: NONE
% spl11-d11 replay events: 14-, 41, 42, 59, 65, 68, 72-, 120
% spl11-d12 replay events: 21, 31++, 41, 49++, 54++, 77, 117
% spl11-d13 replay events: 38-, 40, 96, 130, 131+, 139++
% spl11-d14 replay events: 124++ 
% spl11-d15 replay events: NONE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Potential SLEEP Replay Events
% spl11-d10 replay events: 
% spl11-d11 replay events: 
% spl11-d12 replay events: 2, 5, 7, 11, 23, 35, 39, 54, 58, 62, 76, 115,
% 142, 183, 188++, 251++, 300, 324, 334, 389L, 406, 479, 512
% spl11-d13 replay events: 
% spl11-d14 replay events:
% spl11-d15 replay events: 26, 40, 81?, 224, 283, 396, 423-, 485W, 513,
% 615+, 737, 924+/-, 939, 1020+, 1021+.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear tb pb p1 p2 l;

tb = r(1).tbins;
pb = r(1).pbins;
p1 = r(1).pdf(:,:,1);
p2 = r(2).pdf(:,:,1);

close all;
figure('Position', [500 100 560 800]);
ax(1) = axes('Position', [.05 .5 .9 .45]);
imagesc(tb, pb, 1 - repmat(p1, [1 1 3]), 'Parent', ax(1));
ax(2) = axes('Position', [.05 .02 .9 .45]);
imagesc(tb, pb, 1 - repmat(p2, [1 1 3]), 'Parent', ax(2));

l(1) = line([1 1 1 1 1 1], [1 1 1 1 1 1], 'color', 'r', 'parent', ax(1));
l(2) = line([1 1 1 1 1 1], [1 1 1 1 1 1], 'color', 'r', 'parent', ax(2));

for i = 385:size(b,1)
    x = [b(i,1), b(i, 1), nan, b(i,2), b(i,2)];
    y = max(pb) * [0 1 nan 1 0];
    
    title(ax(1), sprintf('%d', i), 'FontSize', 16);
    set(ax,'XLim', mean(b(i,:)) + [-.25 .25])
    set(l, 'XData', x, 'YData', y);
    
    pause;
    
end