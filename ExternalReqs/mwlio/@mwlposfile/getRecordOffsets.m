function offsets = getRecordOffsets(pf, irange)
%GETRECORDOFFSETS retrieve record byte offsets
%
%  offsets=GETRECORDOFFSETS(f) returns offsets in bytes of all records in the
%  file.
%
%  offsets=GETRECORDOFFSETS(f, range) returns offsets in bytes of all
%  records inthe specified range. Range should be a two element vector
%  indicating start and end of range.
%
%  Note: after completion the current record has been set to the first
%  record in the range.
%


%  Copyright 2005-2008 Fabian Kloosterman

if nargin<2 || isempty(irange)
    irange = [0 pf.nrecords-1];
end

try
    irange = double(irange);
catch
    error('mwlposfile:getRecordOffsets:invalidRange', 'Invalid range argument')
end

if (length(irange)~=2)
    error('mwlposfile:getRecordOffsets:invalidRange', 'Range should be two element vector')
end

if any( fix(irange) ~= irange )
    error('mwlposfile:getRecordOffsets:invalidRange', 'Fractional indices not allowed')
end

pf = setCurrentRecord(pf, irange(1));

n = loadrange(pf,{'nitems'}, irange);
offsets = cumsum([0 ; double(n.nitems(1:end-1)) *3 + 6]) + get(pf, 'headersize');
