
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
    [P4{i}, E4{i}, I4{i}] = decode_feature_vs_cluster(edir{i}, 4);
    [P1{i}, E1{i}, I1{i}] = decode_feature_vs_cluster(edir{i}, 1);

    fprintf('\n');
    
end

%% Save the decoding results

save( '/data/amplitude_decoding/REVISIONS/decode_all_results.mat', 'P1', 'P4', 'E1', 'E4', 'I1', 'I4');


