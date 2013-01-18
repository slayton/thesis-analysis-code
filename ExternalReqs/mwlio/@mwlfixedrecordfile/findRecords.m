function i = findRecords(f, field, bounds)
%FINDRECORDS find records
%
%  idx=FINDRECORDS(f, field, range) returns all indices of the records
%  where the value of the specified fields is within the specified
%  range. This only works for scalar fields.
%


%  Copyright 2005-2008 Fabian Kloosterman


if nargin<3
    help(mfilename)
end

if isnumeric(bounds)
    if length(bounds)==1
        bounds = [bounds bounds];
    end
    
    data = loadField( f, field );
    
    i = find( data>=bounds(1) & data<=bounds(2) );
else
    error('mwlfixedrecordfile:findRecords:invalidRange', 'Invalid range')
end

