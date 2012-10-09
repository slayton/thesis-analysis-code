function [p l] = error_area_plot(x, y, e, varargin)

[ ax, argv, narg] = axescheck(varargin{:});

if isempty(ax)
    ax = axes('Parent', figure);
end

x = x(:)';
y = y(:)';
e = e(:)';

X = [x fliplr(x)];
Y = [y+e fliplr(y-e)];

p = patch(X, Y, [0 0 .508], 'parent', ax);
l = line(x, y,  'parent', ax);


end

