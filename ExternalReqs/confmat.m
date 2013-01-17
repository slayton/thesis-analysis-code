%
% CONFMAT Generates a confusion matrix
%
% c = confmat(x,y)
%
% Author Adrian Chan
%
% This function generates a confusion matrix.
%
% Inputs
%    x: vector of what the signal should have been
%    y: vector of what the signal was classified as
%
% Outputs
%    c: confusion matrix (rows are inputs, colums are outputs)
%
% Modifications
% 00/02/01 AC First created.
% 01/01/18 AC c(i,j) = length(find(z == j))
%				  changed to c(i-minx+1,j-minx+1) = length(find(z == j))
%             This allows any minx.
function c = confmat(x,y, varargin)
args.grid_size = 1;

args = parseArgsLite(varargin,args);

x = round(x./args.grid_size);
y = round(y./args.grid_size);

minx = min(x);
maxx = max(x);

c = zeros(maxx-minx);
for i = minx:maxx
   index = x == i;
   for j = minx:maxx
      z = y(index);
      c(i-minx+1,j-minx+1) = length(find(z == j));
   end
end