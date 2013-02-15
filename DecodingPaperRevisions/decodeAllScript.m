
%% Clear the workspace
clear; clc; close all;
%%
% Define the datasets
ep = 'amprun';
dTypes = {'pos'};

edir = {};

edir{end+1} = '/data/spl11/day13';
edir{end+1} = '/data/spl11/day14';
edir{end+1} = '/data/spl11/day15';
edir{end+1} = '/data/spl11/day16';
edir{end+1} = '/data/jun/rat1/day01';
edir{end+1} = '/data/jun/rat1/day02';
edir{end+1} = '/data/jun/rat2/day01';
edir{end+1} = '/data/jun/rat2/day02';
edir{end+1} = '/data/greg/esm/day01';
edir{end+1}= '/data/greg/esm/day02';
edir{end+1}= '/data/greg/saturn/day02';
edir{end+1}= '/data/fabian/fk11/day08';

nDset = numel(edir);

for i = 1:nDset
    
 
    fprintf('--------------- %s ---------------\n', upper(edir{i}));
    [p{i}, e{i}, in{i}] = decode_feature_vs_cluster(edir{i},'amprun', [1 1 1 1]);
    fprintf('\n');
    
end
%%

E = [e{:}];

er = [E.summary_error];
er = reshape(er, 4, numel(er)/4)';

mi = [E.mutual_info_unbiased_normalized];
mi = reshape(mi, 4, numel(mi)/4)';

idx = [1 3];
er = er(:, idx);
mi = mi(:, idx);
M = in{1}.method(idx);

figure;
boxplot( er ); hold on;
plot(1:numel(idx), er, 'color', [.7 .7 .7]);
set(gca,'XTick', 1:numel(idx), 'XTickLabel', M);
ylabel('Median Error(m)');

[~, pT] = ttest2(er(:,1), er(:,2), .05, 'left');
pR = ranksum(er(:,1), er(:,2), .05, 'tail', 'left');
pS = signrank(er(:,1), er(:,2), .05, 'tail', 'left');

fprintf('\t\tMEDIAN ERROR\n');
fprintf('tTest:%3.5g\tranksum:%3.5g\tsignrank:%3.5g\n', pT, pR, pS);


figure;
boxplot( mi ); hold on;
plot(1:numel(idx), mi, 'color', [.7 .7 .7]);
set(gca,'XTick', 1:numel(idx), 'XTickLabel', M);
ylabel('Mutual Information');

[~, pT] = ttest2(mi(:,1), mi(:,2), .05, 'right');
pR = ranksum(mi(:,1), mi(:,2), .05, 'tail', 'right');
pS = signrank(mi(:,1), mi(:,2), .05, 'tail', 'right');

fprintf('\t\tNORMALIZED MI\n');
fprintf('tTest:%3.5g\tranksum:%3.5g\tsignrank:%3.5g\n', pT, pR, pS);

