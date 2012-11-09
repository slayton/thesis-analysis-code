function [stats, recon] = dset_calc_replay_stats(dset, clIdx, slope, intercept, smooth, trajType)


if isempty(clIdx)
    clIdx = true(size(dset.clusters));
elseif ~islogical(clIdx)
    error('clIdx must be a logical vector');
elseif numel(clIdx) ~= numel(dset.clusters)
    error('Invalid length of clIdx it must be the same size as the dset.clusters struct');
end

if nargin >=4 && xor( isempty(slope), isempty(intercept) )
    error('Must provide both sloper and intercept or neither');
end

if nargin>3 && ~isempty(slope) && ~isempty(intercept) && ~all( size(slope) == size(intercept) )
    error('slope and intercept must be the same size');
end

if nargin<3 
    slope = [];
    intercept = [];
end

if nargin<6
    trajType = 'individual';
end

recon = dset_reconstruct(dset.clusters(clIdx), 'time_win', dset.epochTime, 'tau', .02, 'trajectory_type', trajType);

recon.replayIdx = false(size(recon.tbins));
nCell = size(recon.spike_counts,1);
for i = 1:size(dset.mu.bursts,1)

    tempIdx = recon.tbins >= dset.mu.bursts(i,1) & recon.tbins <= dset.mu.bursts(i,2);
    recon.replayIdx = recon.replayIdx | tempIdx;
    
    if iscell(recon.pdf)
        for j = 1:3

            if isempty(slope) || isempty(intercept)
                stats.pdf{i,j} = recon.pdf{j}(:,tempIdx);
                stats.percentCells(i) = nnz( sum( recon.spike_counts(:, tempIdx), 2) ) / nCell;
                [slp, int, ~]  = est_line_detect(recon.tbins(tempIdx), recon.pbins{j}, recon.pdf{j}(:,tempIdx));
                stats.slope(i,j) = slp;
                stats.intercept(i,j) = int;

            else
                slp = slope(i,j);
                int = intercept(i,j);

            end

            stats.score2(i,j) = compute_line_score(recon.tbins(tempIdx), recon.pbins{j}, recon.pdf{j}(:,tempIdx), slp, int, smooth);
        end
    else
        stats = [];
    end

end

end

