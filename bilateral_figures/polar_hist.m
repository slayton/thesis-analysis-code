function [h, ax] = polar_hist(ax, data, bins,  normalize)

% if the first input argument isn't an axes object, then shift the values
% of the input args appropriately

if isempty( axescheck(ax) )
    
    if nargin==4
        error('Invalid axes handle provided');
    end
    
    if nargin>=3
        normalize = bins;
    end
    
    if nargin>=2
        bins = data;
    end
    
    if nargin>=1
        data = ax;
        ax = [];
    end
end

if ~exist('bins', 'var') || isempty(bins)
    bins = -(pi * 7/8 ) : pi/8 : pi;
elseif ~isvector(bins) && ~ismonotonic(bins)
    error('bins must be a monotonically increasing vector');
end

if ~exist('normalize', 'var') || isempty(normalize)
    normalize = 0;
elseif ~isscalar(normalize) && any(normalize == [0 1])
    error('normalize must be equal to 0 or 1');
end


% Compute the histogram counts.
[t, r] = rose(data, bins);

if normalize == 1
    r = r ./ sum(r) ;
end

[x,y] = pol2cart(t,r);


% save the largest radius in the histogram
R = max(r) * 1;

if isempty(ax)
    ax = createPolarAxes(R); 
end

h = patch(x,y,'b', 'parent', ax, 'linewidth', 2);

data = get(ax, 'UserData');
data.hObj(end+1) = h;
set(ax,'UserData', data);

end



function data = checkIfPolarAxes(ax)
    data = get(ax,'UserData');
    if isempty(data) || ~isfield(data, 'type') || ~strcmp(data.type, 'polar')
        error('The Axes object is not configured as a polar axes');
    end

end

function ax = createPolarAxes(R)
    disp('Creating a new polar axes');
    %create the figure
    f = figure;
    ax = axes('Parent', f, 'Units', 'pixels');
    
    % make the Axes square in pixel space
    fPos = get(f, 'Position');
    dim = min( fPos(3:4) );
    
    axPos = [ ...
        (fPos(3) - dim)/2 + 5,  ...
        (fPos(4) - dim)/2 + 5, ...
        dim - 10, dim - 10];
    
    % set the values on the axes
    set(ax,'Position', axPos , 'Color', 'none', 'Units', 'normal');
    set(ax, 'XTick', [], 'YTick', [], 'XLim', R * [-1.2 1.2], 'Ylim', R * [-1.2 1.2]);
       
    % save the parameters for later access
    data.type = 'polar';
    
    data.R = R;
    
    data.rTick = defineRadialTicks(R);
    data.aTick = defineAngularTicks(R);
    
    data.hObj = [];
    
    set(ax,'UserData', data);
    
    renderPolarAxes(ax);
end

function [rTicks] = defineRadialTicks(R)
    
    rTicks = R/3 * [3 2 1];
        
end

function [aTicks] = defineAngularTicks(R)
    aTicks = (0:2:7)/2;
end

function renderPolarAxes(ax)

    data = checkIfPolarAxes(ax);
      
     % Render the OUTER ring
    data.handles.polarAxes = ...   
    circle(ax, [0 0], data.R, 'edgecolor', 'k', 'linewidth', 2, 'facecolor', 'w');
    
    % Render the ANGULAR ticks and labels
    [data.handles.aTick, data.handles.aLab] = ...
        renderAngularTicks(ax, data.aTick, data.R);
    
    % Render the RADIAL ticks and labels
    [data.handles.rTick, data.handles.rLab] = ...
        renderRadialTicks(ax, data.rTick);
    
    
       
end

function [t, l] = renderRadialTicks(ax, rTick)
    % draw the maxes marks
    nTick = numel(rTick);
    
    [t, l] = deal( zeros(nTick,1) );
    
    for i = 1:nTick
       
       [x, y] = pol2cart(pi/4, rTick(i) );
       
       t(i) = circle([0 0], rTick(i), 'EdgeColor', [.4 .4 .4], 'FaceColor', 'none', 'linestyle', '--', 'Parent', ax);
       l(i) = text(x, y, sprintf('%3.2f', rTick(i)), 'FontSize', 14);
    end
    
end

function [tick, lab] = renderAngularTicks(ax, aTick, R)

    nTick = numel(aTick);
    [tick, lab] = deal(zeros(nTick, 1));
    
    for i = 1:numel(aTick)
        
        
        [x, y] = pol2cart(pi/2 * aTick(i), R);
            
        tick(i) = line(x * [-1 1], y * [-1 1], 'Color', 'k', 'linewidth', 1,'Parent', ax);
        
            lab(i) = text(1.05*x, 1.05*y, sprintf('%2.2f', pi * aTick(i)/2), 'FontSize', 14, 'Parent', ax);
       

            if abs(x) < .0005
                set(lab(i),'HorizontalAlignment', 'center')
            elseif x>0
                set(lab(i),'HorizontalAlignment', 'left');
            else
                set(lab(i),'HorizontalAlignment', 'Right');
            end

            if abs(y) < .0005 
                set(lab(i),'VerticalAlignment', 'top');
            elseif y>0
                set(lab(i), 'VerticalAlignment', 'bottom');
            else
                set(lab(i), 'VerticalAlignment', 'top');
            end
         
        
    end    
%     
%     tick(1) = line(R * [-1, 1], [0, 0], 'color', 'k', 'parent', ax);
%     tick(2) = line([0, 0], R * [-1, 1], 'color', 'k', 'parent', ax);
%     tick(3) = line(sqrt(2)/2 * [-R R], sqrt(2)/2 * [R -R], 'color', 'k', 'parent', ax);
%     tick(4) = line(sqrt(2)/2 * [R -R], sqrt(2)/2 * [R -R], 'color', 'k', 'parent', ax);
% 
%     lab(1) = text(1.05*R, 0, '2\pi',      'fontsize', 14, 'HorizontalAlignment', 'left', 'verticalalignment', 'middle');
%     lab(2) = text(-1.075*R, 0, '\pi',     'fontsize', 14, 'HorizontalAlignment', 'right','verticalalignment', 'middle');
%     lab(3) = text(0, 1.05*R, '\pi/_2',    'fontsize', 14, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
%     lab(4) = text(0, -1.05*R, '3\pi/_2', 'fontsize', 14, 'horizontalalignment', 'center', 'verticalalignment', 'top');

end