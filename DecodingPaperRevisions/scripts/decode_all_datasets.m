
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
[P1, P4, E1, E4, I1, I4] = deal( repmat({}, nDset,1) );

for i = 1:nDset
   
    fprintf('--------------- %s ---------------\n', upper(edir{i}));
    [P1{i}, E1{i}, I1{i}] = decode_feature_vs_cluster(edir{i}, 1);
    [P4{i}, E4{i}, I4{i}] = decode_feature_vs_cluster(edir{i}, 4);
    fprintf('\n');
    
end

% save( '/data/amplitude_decoding/NEW_FIGURES/decodingResults.mat', 'PR', 'ER', 'IN');


%%
P = P4; E = E4; I = I4;

n = numel(E{1});
e = [E{:}];

er = [e.summary_error];

er = reshape(er, [n, numel(E)])';

M = I{1}.method;

close all;
f = figure;
subplot(121);
set(gca,'FontSize', 14);

boxplot( er ); hold on;
plot(1:2, er, 'color', [.7 .7 .7]);
set(gca,'XTick', 1:2, 'XTickLabel', M);
ylabel('Median Error(m)');

[~, pT] = ttest2(er(:,1), er(:,2), .05, 'left');
pR = ranksum(er(:,1), er(:,2), .05, 'tail', 'left');
pS = signrank(er(:,1), er(:,2), .05, 'tail', 'left');

fprintf('\t\tMEDIAN ERROR\n');
fprintf('tTest:%3.5g\tranksum:%3.5g\tsignrank:%3.5g\n', pT, pR, pS);
title( sprintf('%d Channel Decoder Comparison', 4) );
ylabel('Median Error(m)');

P = P1; E = E1; I = I1;

n = numel(E{1});
e = [E{:}];

er = [e.summary_error];

er = reshape(er, [n, numel(E)])';


subplot(122);
set(gca,'FontSize', 14);

boxplot( er ); hold on;
plot(1:2, er, 'color', [.7 .7 .7]);
set(gca,'XTick', 1:2, 'XTickLabel', M);
ylabel('Median Error(m)');

[~, pT] = ttest2(er(:,1), er(:,2), .05, 'left');
pR = ranksum(er(:,1), er(:,2), .05, 'tail', 'left');
pS = signrank(er(:,1), er(:,2), .05, 'tail', 'left');

fprintf('\t\tMEDIAN ERROR\n');
fprintf('tTest:%3.5g\tranksum:%3.5g\tsignrank:%3.5g\n', pT, pR, pS);
title( sprintf('%d Channel Decoder Comparison', 1) );
ylabel('Median Error(m)');

plot2svg('/data/amplidute_decoding/NEW_FIGURES/feature_vs_identity.svg', gcf)