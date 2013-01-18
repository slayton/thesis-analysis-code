function val = get(ef, propName)
%GET get mwleegfile properties
%
%  val=GET(f, property) returns the value of the specified mwleegfile
%  object property. Valid properties are (in addition to those inherited
%  from its base classes):
%  nsamples - number of samples / channel in a data buffer
%  nchannels - number of data channels
%
%  See also MWLFIXEDRECORDFILE, MWLRECORDFILEBASE, MWLFILEBASE
%

%  Copyright 2005-2008 Fabian Kloosterman

try
    val = ef.(propName);
catch
    val = get(ef.mwlfixedrecordfile, propName);
end

