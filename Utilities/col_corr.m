function [C] = col_corr(A, B)
%COL_CORR compute the column by column correalion between two matrices
% C=COL_CORR(A, B) computes the correlation for each set of columns in A
% and B of identical size
%
% This function produces nearly identical results as diag( corr( A,B ))
% and can be run on very large matrices where as diag( corr( A,B )) is
% limited in size by Matlab.  
%
% See also diag corr col_corr_slow


% Source based on: http://tinyurl.com/6njmwca (see below for complete URL)
% http://stackoverflow.com/questions/9262933/what-is-a-fast-way-to-compute-column-by-column-correlation-in-matlab
%

% Copyright Stuart Layton



% Check the inputs

if ~all(size(A) == size(B))
    error('A and B must be the same size');
end


An=bsxfun(@minus,A,mean(A,1));
Bn=bsxfun(@minus,B,mean(B,1));
An=bsxfun(@times,An,1./sqrt(sum(An.^2,1)));
Bn=bsxfun(@times,Bn,1./sqrt(sum(Bn.^2,1)));

C=sum(An.*Bn,1);

