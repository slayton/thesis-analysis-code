function fi = fisherinfo(pfs)
% FISHERINFO estimate of fisher information in a series
% $Id: fisherinfo.m 419 2007-08-29 23:16:05Z tjd $
%
% pf hists are in rows!
%
% fmla: 
% sum over all i: f'(i)^2 / f(i)
%  
% this is an estimate. From appendix B of 
%
%The Journal of Neurophysiology Vol. 79 No. 2 February 1998, pp. 1017-1044
%Interpreting Neuronal Population Activity by Reconstruction: Unified
%Framework With Application to Hippocampal Place Cells 
%Kechen Zhang, Iris Ginzburg, Bruce L. McNaughton, and Terrence J. Sejnowski
 
  nrows = size(pfs,1);
  
  fi = zeros(nrows,1);
  
  for k=1:nrows;
    % row-wise slope
    oldwarn = warning('off','matlab:dividebyzero');
    firow = diff(pfs(k,:)).^2./ mean([pfs(k,1:end-1);pfs(k,2:end)]) ;
    warning(oldwarn);
    fi(k) = sum(firow(~isnan(firow))); % leave the rest zeros
  end
  