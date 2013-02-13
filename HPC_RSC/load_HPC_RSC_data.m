function [mu, eeg] = load_HPC_RSC_data()

%{'spl11', 'spl11', 'spl11'}, [15 12 11], [2 1 2];
base = {'gh-rsc1', 'gh-rsc2', 'spl11'};
bId = [1 1 1 1 1 2 2 2 2];
day = [18, 22, 23, 24, 28, 22, 24, 25, 26];
ep = [3, 1, 1, 2, 3, 3, 3, 3, 3];


fprintf('\nLOADING THE RAW DATA\n');
mu = {};
eeg = {};

for E = 1:numel(bId);
    
    % LOAD THE DATA
    epoch = sprintf('sleep%d', ep(E));
    edir = sprintf('/data/%s/day%d', base{bId(E)}, day(E));
    fName = sprintf('MU_HPC_RSC_%s.mat', upper(epoch));
    fprintf('%s %d %s', base{bId(E)}, day(E), fName );
    tmp = load( fullfile(edir, fName) );
    mu{E} = tmp.mu;
    
    if nargout>1
        fName = sprintf('EEG_HPC_1500_%s.mat', epoch);
        fprintf(', %s', fName );
        tmp = load( fullfile(edir, fName) );
        eeg{E} = tmp.hpc;
    end
    fprintf('\n');
end

fprintf('---------------DATA LOADED!---------------\n');


end