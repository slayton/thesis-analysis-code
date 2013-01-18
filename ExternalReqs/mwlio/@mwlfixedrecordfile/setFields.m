function frf = setFields(frf, fields)
%SETFIELDS create fields for new fixed record file
%
%  f=SETFIELDS(f, fields) sets the fields for a mwl fixed record
%  file. The fields arguments should be a valid mwlfield object.
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<2
  help(mfilename)
  return
end

frf.mwlrecordfilebase = setFields(frf.mwlrecordfilebase, fields);

fields = get(frf, 'fields');

frf.recordsize = sum( bytesize(fields) );

