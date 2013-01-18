function frf = setFieldsInterp(frf, fields)
%SETFIELDSINTERP set reinterpretation fields
%
%  rfb=SETFIELDINTERP(rfb,fields) sets field descriptions that
%  should be used to reinterpret the data while loading/saving. These
%  field descriptions will be used instead of the field description
%  stored in the header of the file. Note that the size of a record
%  cannot change.
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<2
  help(mfilename)
  return
end

if ~isempty(fields) && ~isa(fields,'mwlfield')
  error('mwlrecorfilebase:setFields:invalidFields', 'Invalid fields')
end

if sum( bytesize(fields) ) ~= frf.recordsize
  error('mwlfixedrecordfile:setFieldInterp:invalidFields', ['Record size ' ...
                      'cannot change'])
end

frf.mwlrecordfilebase = setFieldsInterp(frf.mwlrecordfilebase, fields);
