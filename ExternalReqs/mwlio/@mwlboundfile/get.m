function val = get(bf, propName)
%GET get mwlboundfile properties
%
%  val=GET(f, property) returns the value of the specified mwlboundfile
%  object property. Valid properties are the same as the base class
%  mwlfilebase.
%
%  Example
%    f = mwlboundfile('test.dat')
%    h = get(f,'header');
%
%  See also MWLFILEBASE
%

%  Copyright 2005-2008 Fabian Kloosterman

try
    val = bf.(propName);
catch
    val = get(bf.mwlfilebase, propName);
end
