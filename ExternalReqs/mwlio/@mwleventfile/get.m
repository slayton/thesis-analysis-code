function val = get(ef, propName)
%GET get mwleventfile properties
%
%  val=GET(f, property) returns the value of the specified mwleventfile
%  object property. Valid properties are (in addition to those inherited
%  from its base classes):
%  string_size - number of characters in an event string
%
%   See also MWLFIXEDRECORDFILE, MWLRECORDFILEBASE, MWLFILEBASE
%

%  Copyright 2005-2008 Fabian Kloosterman

try
    val = ef.(propName);
catch
    val = get(ef.mwlfixedrecordfile, propName);
end
