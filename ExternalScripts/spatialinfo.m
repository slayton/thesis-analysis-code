function sis = spatialinfo(pfs)
% SPATIALINFO Skaggs93 spatial info for a normalized place field
% $Id: spatialinfo.m 419 2007-08-29 23:16:05Z tjd $
%
% pf hists are in rows!
%
% fmla: for all i sum p(i)*(lambda(i)/lambda)*log2(lambda(i)/lambda)
%
% where:
%  p(i) probability of occupancy of rat in in bin i (sums to 1)
%  lambda mean firing rate of cell
%  lambda(i) firing rate of cell in bin i
  
% since bins are already occupancy normalized, we can move the p(i) out
% of the sum, and just divide by the # of bins.

  % preallocate
  sibins = zeros(size(pfs));
  pfsnorm = sibins;

  for pfi = 1:size(pfs,1);
    if any(pfs(pfi,:)) > 0, % don't calc if all are zero (zero si)
      pfsnorm(pfi,:) = pfs(pfi,:)./mean(pfs(pfi,:));
    end
  end
  
  nonzero = pfsnorm>0;
  
  sibins(nonzero) = pfsnorm(nonzero) .* log2(pfsnorm(nonzero));
  sis = sum(sibins,2)/size(pfs,2);