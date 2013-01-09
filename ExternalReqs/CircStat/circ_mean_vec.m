function [t, r] = circ_mean_vec(T, R)

% 
% 
% if ~isvector(T) || ~isvector(R)
%     error('Theta and Rho must be vectors');
% end
% if numel(T) ~= numel(R)
%     error('Theta and Rho must be the same size');
% end
% 
% 
% t = circ_mean(T(:), R(:));
% r = circ_r(T(:), R(:));


[X, Y] = pol2cart(T, R);

x = mean(X);
y = mean(Y);

[t, r] = cart2pol(x,y);


end