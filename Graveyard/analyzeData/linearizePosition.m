function [degs h] = linearizePosition(x, y, track)
% linearizePosition(x,y,trackType)
% returns a vector with linearized position.  
% 
% Types of calculations available:
%   circle - linearize a circular track

if ~strcmp(track, 'circle')
    disp('Current can only convert circular track');
    return;
end;

h = sqrt(double(x).^2 + double(y).^2);
degs = (180/pi) *atan2(double(y),double(x));
