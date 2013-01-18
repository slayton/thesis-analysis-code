function rfb = setFieldsInterp(rfb, fields)
%SETFIELDSINTERP set reinterpretation fields
%
%  rfb=SETFIELDINTERP(rfb,fields) sets field descriptions that
%  should be used to reinterpret the data while loading/saving. These
%  field descriptions will be used instead of the field description
%  stored in the header of the file. Note that it is up to the derived
%  classes to implement this functionality.
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<2
  help(mfilename)
  return
end

if ~isempty(fields) && ~isa(fields,'mwlfield')
  error('mwlrecordfilebase:setFieldsInterp:invalidFields', 'Invalid fields')
end

rfb.fields_interpretation = fields;
