function [x,y] = ellipse_points(z,a,b,alpha)
    z = z(:);
    % form the parameter vector
    npts = 100;
    t = linspace(0, 2*pi, npts);

    % Rotation matrix
    Q = [cos(alpha), -sin(alpha); sin(alpha) cos(alpha)];
    % Ellipse points
    X = Q * [a * cos(t); b * sin(t)] + repmat(z, 1, npts);

    x = X(1,:);
    y = X(2,:);

end