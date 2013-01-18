function data = loadField(frf, loadfield, irange)
%LOADFIELD load single field from fixed record file
%
%  data=loadField(f, field) returns the data in the specified field from
%  all records in the file.
%
%  data=LOADFIELD(f, field, record_range) loads only the records in the
%  specified range. Record_range should be a two element vector with the
%  start and end record indices of the range.
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<2
    help(mfilename)
    return
end

fields = get(frf, 'fields_interpretation');
if isempty(fields)
  fields = get(frf, 'fields');
end
nfields = numel(fields);
nrecords = get(frf, 'nrecords');

if isempty(loadfield) || ~ischar(loadfield)
    error('mwlfixedrecordfile:loadField:invalidField', 'Please specify a valid field')
else
    [dummy, fieldid] = ismember( cellstr(loadfield), name(fields)); %#ok
    if fieldid==0
        error('mwlfixedrecordfile:loadField:invalidField','Unknown field')
    end
end

isbinary = ismember( get(frf, 'format'), 'binary');

if nargin<3 || isempty(irange)
    if isbinary
        irange = [0 nrecords-1 ];
    else
        irange = [0 -1];
    end
elseif ~isnumeric(irange) || numel(irange)~=2
    error('mwlfixedrecordfile:loadField:invalidRange','Invalid range')
else
    irange = double(irange);
end

if any( fix(irange) ~= irange )
    error('mwlfixedrecordfile:loadField:invalidRange','Fractional indices not allowed')
end


fid = fopen( fullfile( get(frf, 'path'), get(frf, 'filename') ), 'r' );

if fid == -1
    error('mwlfixedrecordfile:loadField:invalidFile','Cannot open file')
end

if ismember(get(frf, 'format'), {'binary'})

    if irange(2)==-1
        irange(2) = nrecords-1;
    elseif irange(1)>irange(2) || irange(1)<0 || irange(2)>nrecords
        error('mwlfixedrecordfile:loadField:invalidRange', 'Invalid range')
    end
    
    offset = byteoffset( fields );
    offset = offset( fieldid );

    fseek(fid, get(frf, 'headersize') + offset + frf.recordsize * irange(1), -1);

    data = fread( fid, length(fields(fieldid))*(diff(irange)+1), [num2str(length(fields(fieldid))) '*' char(matcode(fields(fieldid)))], frf.recordsize - bytesize(fields(fieldid)));
    
    data = reshape(data, [size(fields(fieldid)) diff(irange)+1]);
    
else %ascii file
    
    %create format string for textscan
    skip = ones(nfields,1);
    skip(fieldid)=0;
    fmt = formatstr(fields, skip);
    %fseek to header offset
    fseek(fid, get(frf, 'headersize'), -1);
    %do a textscan for (endid-startid+1) lines
    if irange(2)==-1
        data = textscan(fid, fmt, 'headerLines', irange(1));
    elseif irange(1)<=irange(2) && irange(1)>=0
        data = textscan(fid, fmt, diff(irange)+1, 'headerLines', irange(1));
    else
        error('mwlfixedrecordfile:loadField:invalidRange', 'Invalid range')
    end
    
    %transform data to matrix if necessary
    if strcmp(type(fields(fieldid)), 'string')
      data = data{1}(:)';
    else
      nrows = numel(data{1});
      data = cell2mat(data);
      nd = numel( size(fields(fieldid)) );
      data = permute( reshape( data, [ nrows size(fields(fieldid))] ), [(1:nd)+1 1]);
    end
    
end

fclose(fid);
