function [mu, HPC, CTX] = load_HPC_RSC_data(skip)

%{'spl11', 'spl11', 'spl11'}, [15 12 11], [2 1 2];
base = {'gh-rsc1', 'gh-rsc2', 'spl11'};
bId = [1 1 1 1 1 2 2 2 2];
day = [18, 22, 23, 24, 28, 22, 24, 25, 26];
ep = [3, 1, 1, 2, 3, 3, 3, 3, 3];


fprintf('\nLOADING THE RAW DATA\n');

if nargin == 0
    skip = 1;
end

for i = 1:numel(bId);
    
    % LOAD THE DATA
    epoch = sprintf('sleep%d', ep(i));
    edir = sprintf('/data/%s/day%d', base{bId(i)}, day(i));
    fName = sprintf('MU_HPC_RSC_%s.mat', upper(epoch));
    fprintf('%s %d %s', base{bId(i)}, day(i), fName );
    tmp = load( fullfile(edir, fName) );
    mu(i) = tmp.mu;
    
    if nargout>1
        fName = sprintf('EEG_HPC_1500_%s.mat', epoch);
        fprintf(', %s', fName );
        tmp = load( fullfile(edir, fName) );
        
        if ~skip
            HPC(i) = orderfields(tmp.hpc);
        else
            HPC(i).ts = tmp.hpc.ts;
            HPC(i).lfp = tmp.hpc.lfp;
        end
    end
    if nargout>2
        fName = sprintf('EEG_CTX_1500_%s.mat', epoch);
        fprintf(', %s', fName );
        tmp = load( fullfile(edir, fName) );
        CTX(i).ts = tmp.ctx.ts;
        CTX(i).lfp = tmp.ctx.data;
    end
    fprintf('\n');
end

fprintf('---------------DATA LOADED!---------------\n');


end