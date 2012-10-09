function [p] = dset_calc_replay_significance(stats, shuffles, alpha)
    
    if ~isscalar(stats) && isstruct(stats)
        error('Stats must be a single struct');
    end
    
    if ~iscell(shuffles)
        error('Shuffles must be a cell array of shuffle distributions')
    end
    
    
    if nargin<3
        alpha = .05;
    elseif isempty(alpha) || alpha < 0 || alpha > 1 
        error('alpha cannot be empty and must be between 0 and 1');
    end
   
    nShuffle = numel(shuffles);
    
    nEvent = size(shuffles{1}, 1);
    
    p = nan(nEvent, nShuffle);
    
    [maxScore, bestIdx] = max(stats.score2, [], 2);
    
    for i = 1:nShuffle
        for j = 1:nEvent
            p(j, i) = 1 - sum( stats.score2(j,bestIdx(j)) > shuffles{i}(j,bestIdx(j),:) )  / nShuffle;       
        end
    end


end