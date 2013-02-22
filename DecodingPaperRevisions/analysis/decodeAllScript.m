
%% Clear the workspace
clear; clc; close all;
%%
% Define the datasets
ep = 'amprun';
dTypes = {'pos'};

edir = {};

edir{end+1} = '/data/spl11lo/day13';
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
[PR, ER, IN] = deal( repmat({}, nDset,1) );

for i = 1:nDset
   
    fprintf('--------------- %s ---------------\n', upper(edir{i}));
    [PR{i}, ER{i}, IN{i}] = decode_feature_vs_cluster(edir{i});
    fprintf('\n');
    
end

save( '/data/amplitude_decoding/NEW_FIGURES/decodingResults.mat', 'PR', 'ER', 'IN');


%%

e = [ER{:}];

er = [e.summary_error];
er = reshape(er, 7, numel(er)/7)';

mi = [e.mutual_info_unbiased_normalized];
mi = reshape(mi, 7, numel(mi)/7)';

idx = [1 2 3 4 5 6 7];
er = er(:, idx);
mi = mi(:, idx);
%M = {'All:Feat', 'Clust:Feat', 'All:Iden', 'Sorted:Iden'};
M = IN{1}.method(idx);

close all;
figure;
subplot(211);
set(gca,'FontSize', 14);

boxplot( er ); hold on;
plot(1:numel(idx), er, 'color', [.7 .7 .7]);
set(gca,'XTick', 1:numel(idx), 'XTickLabel', M);
ylabel('Median Error(m)');

[~, pT] = ttest2(er(:,1), er(:,2), .05, 'left');
pR = ranksum(er(:,1), er(:,2), .05, 'tail', 'left');
pS = signrank(er(:,1), er(:,2), .05, 'tail', 'left');

fprintf('\t\tMEDIAN ERROR\n');
fprintf('tTest:%3.5g\tranksum:%3.5g\tsignrank:%3.5g\n', pT, pR, pS);
title('Decoder Comparison');
ylabel('Median Error(m)');

subplot(212);
set(gca,'FontSize', 14);

boxplot( mi ); hold on;
plot(1:numel(idx), mi, 'color', [.7 .7 .7]);
set(gca,'XTick', 1:numel(idx), 'XTickLabel', M);
ylabel('Mutual Information');

[~, pT] = ttest2(mi(:,1), mi(:,2), .05, 'right');
pR = ranksum(mi(:,1), mi(:,2), .05, 'tail', 'right');
pS = signrank(mi(:,1), mi(:,2), .05, 'tail', 'right');

fprintf('\t\tNORMALIZED MI\n');
fprintf('tTest:%3.5g\tranksum:%3.5g\tsignrank:%3.5g\n', pT, pR, pS);
title('Decoder Comparison');
ylabel('Mutual Information (Normalized)');

save_new_decoding_figures('feature_vs_cluster_accuracy', gcf);

%%

% in = cell2mat(in);
in = cell2mat(IN);
data = {in.data};

totalSpike = [];
sortedSpike = [];
for i = 1:numel(data)
    d = data{i};
    totalSpike(i) = sum(cellfun(@(x)(size(x,1)), d{1}));
    sortedSpike(i) = sum(cellfun(@(x)(size(x,1)), d{2}));
end

