classdef data_source 
    methods (Abstract)
      data = get_data(tstart, tend, sources)
      source = get_source()
    end
end
