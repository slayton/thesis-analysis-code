function data = loadrange(frf, loadflds, irange, rangefield)
%LOADRANGE load data from mwl pos file
%
%  data=LOADRANGE(f) load all records from a mwl pos file. The returned
%  data is a structure with 'nitems', 'frame', 'timestamp' and 'pos'
%  fields. The 'pos' field is a struct array with fields 'x' and 'y'.
%
%  data=LOADRANGE(f, fields) load only the fields specified. The fields
%  argument can be a string or a cell array of strings. If this argument
%  contains 'all', then all fields are loaded. Valid fields for a mwl pos
%  file are: 'nitems', 'frame', 'timestamp', 'target x', 'target y'.
%
%  data=LOADRANGE(f, fields, range) loads only the records in the
%  specified range. The range argument is a two element vector specifying
%  the start and end of a range.
%
%  data=LOADRANGE(f, fields, range, 'timestamp') the range is specified
%  in timestamps rather than record indices.
%
%  Note: random access is not supported
%

%  Copyright 2005-2008 Fabian Kloosterman

fields = get(frf, 'fields');

if nargin<2 || isempty(loadflds)
    loadflds = name(fields);
elseif ischar(loadflds)
    loadflds = {loadflds};
elseif ~iscell(loadflds)
    error('mwlposfile:loadrange:invalidFields', ...
          'Invalid fields')
end

if ismember( 'all', loadflds )
    loadflds = name(fields);
end

if nargin<3 || isempty(irange)
    irange = [frf.currentrecord frf.nrecords-1 ];
elseif ~isnumeric(irange) || numel(irange)~=2
    error('mwlposfile:loadrange:invalidRange', 'Invalid range')
else
    irange = double(irange);
end

if any( fix(irange) ~= irange )
    error('mwlposfile:loadrange:invalidRange', 'Fractional indices not allowed')
end

[dummy, id] = ismember( loadflds, name(fields)); %#ok
id( id==5 ) = 4; %because we are treating target x and target y fields as one pos field
fieldmask = sum( bitset(0, unique(id( id~=0 )) ) );

if fieldmask==0
    error('mwlposfile:loadrange:invalidFields', 'Invalid fields')
end

if nargin<4 || isempty(rangefield)
    %range = record indices
    frf = setCurrentRecord(frf, irange(1));
    data = posloadrecordrange( fullfile(frf), frf.currentoffset, irange(2)-irange(1)+1, fieldmask);
else
  if ~strcmp( rangefield, 'timestamp' )
    error('mwlposfile:loadrange:invalidRangeField', 'Filtering only supported for timestamp field')
  end
    
  idrange = posfindtimerange(fullfile( frf ), get(frf, 'headersize'), irange);
  frf = setCurrentRecord(frf, idrange(1));
  data = posloadrecordrange(fullfile( frf ), frf.currentoffset, idrange(2)-idrange(1)+1, fieldmask);

end

