function val = get(rfb, propName)
%GET get mwlrecordfilebase properties
%
%  val=GET(f, property) returns the value of the specified
%  mwlrecordfilebase object property. Valid properties are (in addition
%  to those inherited from its base classes):
%  fields - record field descriptions
%
%  See also MWLFILEBASE
%

%  Copyright 2005-2008 Fabian Kloosterman

try
    val = rfb.(propName);
catch
    val = get(rfb.mwlfilebase, propName);
end
