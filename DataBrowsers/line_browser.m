function a = line_browser(data, ts, varargin)
% line_browser(data, ts, varargin), returns handles to line objects that
% are plotted dynamically

args.color = 'b';
args.axes = [];
args.offset = 0;
args = parseArgsLite(varargin, args);
a = axescheck(args.axes);

if isempty(a)
    figure();
    a = axes();
    disp('No Axes specified, creating them');
end

if nargin == 1 || isempty(ts)
    timestamps = 1:length(data);
else
    timestamps = ts;
end

if size(data,1)>1 && numel(args.color)==1
    args.color = repmat(args.color, size(data,1),1);
end

if args.offset~=0
    for idx=1:size(data,2)
        data(:,idx)= data(:,idx)+args.offset*idx;
    end
end

xlim_listener = addlistener(a, 'XLim', 'PostSet', @(src,e) refresh);
dest_listener = addlistener(a, 'ObjectBeingDestroyed', @(src, e) destroy);

aObj = [];

set(a, 'Units', 'Pixels', 'XLim', [min(timestamps) max(timestamps)]);
set(a, 'Units', 'Normalized');


    function refresh()
       
        if ~ishandle(a) | ~ishandle(aObj) %#ok
            delete(xlim_listener);
            if ~ishandle(aObj)
                delete(aObj);
            end
            return
        end
        
        if isempty(aObj)
            for i=1:size(data,2)
                if isvector(args.color)
                    c_tmp = args.color(i);
                else
                    c_tmp = args.color(i,:);
                end
                aObj(i) = line([1],[1], 'Parent', a,'color', c_tmp);
            end
        end
        
        lims = get(a, 'XLim');
        [wave times] = get_wave_data(lims(1), lims(2));
        refresh_plot(wave, times);
    end

    function refresh_plot(wave, times)        
        for i=1:size(data,2)
            set(aObj(i), 'XData', times, 'YData', wave(:,i));
        end
    end

    function [wave times] =  get_wave_data(ts, te)
        
        ind1 = find(timestamps>ts, 1, 'first');
        ind2 = find(timestamps<te, 1, 'last');       
        ind1 = max([ind1-30, 1]);
        ind2 = min([ind2+30, numel(timestamps)]);
        
        ind = ind1:ind2;
        %ind = ind(ind>100 & ind<length(timestamps));
        n_points = length(ind);
        if (n_points>25000)
            ind = sort(randsample(ind,25000));
        end
        times = timestamps(ind);
        
        wave = data(ind,:);
    end

    function destroy()
       %disp('object getting destroyed');
       delete(xlim_listener)
       delete(dest_listener)
        
    end

end