function [s] = dset_get_description_string(d)
    if ~isfield(d, 'description')
        error('No description data to work with');
    end
    
    s = sprintf('%s %d:%d', d.description.animal, d.description.day, d.description.epoch);
    

end