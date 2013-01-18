function val = get(pf, propName)
%GET get oject properties
%
%  val=GET(f, property) returns the value of the specified mwlposfile
%  object property. Valid properties are (in addition to those inherited
%  from its base classes):
%  nrecords - number of records in file
%  currentrecord - current record (where file cursor is)
%  currentoffset - offset of current record in file
%  currenttimestamp - timestamp of current record
%
%  See also MWLRECORDFILEBASE, MWLFILEBASE
%


%  Copyright 2005-2008 Fabian Kloosterman

try
    val = pf.(propName);
catch
    val = get(pf.mwlrecordfilebase, propName);
end

