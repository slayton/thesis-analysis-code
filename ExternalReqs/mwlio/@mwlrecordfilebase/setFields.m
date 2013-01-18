function rfb = setFields(rfb, fields)
%SETFIELDS create fields for new record file
%
%  f=SETFIELDS(f, fields) sets the record field descriptions. Fields
%  should be a valid mwlfield object.
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<2
  help(mfilename)
  return
end

if ~ismember(get(rfb, 'mode'), {'write', 'overwrite'})
    error('mwlrecordfilebase:setFields:invalidMode', 'File is not in write mode')
end

if ~isa(fields, 'mwlfield')
    error('mwlrecorfilebase:setFields:invalidFields', 'Invalid fields')
end

rfb.fields = fields;

