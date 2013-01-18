function f = setCurrentRecord(f, recid)
%SETCURRENTRECORD move file pointer to record
%
%  f=SETCURRENTRECORD(f, record) sets the file cursor to the requested
%  record.
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<2
  help(mfilename)
  return
end

if ismember(get(f, 'mode'), {'write', 'overwrite'})
    error('mwlposfile:setCurrentRecord:invalidMode', 'Cannot set current record in write mode')
end

if recid > get(f, 'nrecords') || recid<0
    error('mwlposfile:setCurrentRecord:invalidRecord', ...
          'Invalid record index')
end

if any( fix(recid) ~= recid )
    error('mwlposfile:setCurrentRecord:invalidRecord', ...
          'Fractional indices not allowed')
end

if recid == f.currentrecord
    offset = f.currentoffset;
    index = 0;
    record = f.currentrecord;
elseif recid < f.currentrecord
    %search from start of file
    offset = get(f, 'headersize');
    index = recid;
    record = 0;
else
    %search from current record
    offset = f.currentoffset;
    index = recid - f.currentrecord;
    record = f.currentrecord;
end

[newrecid, newoffset, newtimestamp] = posfindrecord( fullfile(get(f, 'path'), get(f, 'filename')), offset, index );

f.currentrecord = record + newrecid;
f.currentoffset = newoffset;
f.currenttimestamp = newtimestamp;
