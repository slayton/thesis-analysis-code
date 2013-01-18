function val = get(frf, propName)
%GET get mwlfixedrecordfile properties
%
%  val=GET(f, property) returns the value of the specified mwlfixedrecordfile
%  object property. Valid properties are (in addition to those inherited
%  from its base classes):
%  recordsize - size in bytes of a record
%  nrecords - number of records in the file
%
%  See also MWLFILEBASE
%

%  Copyright 2005-2008 Fabian Kloosterman

if strcmp( 'nrecords', propName)
    if ismember(get(frf, 'format'), {'binary'})
        if ismember( get(frf, 'mode'), {'read', 'append'} )    
            val = (get(frf, 'filesize') - get(frf, 'headersize') ) ./ frf.recordsize;
        else
            val = -1;
        end
    else
        val = -1;
    end
    
else
    
    try
        val = frf.(propName);
    catch
        val = get(frf.mwlrecordfilebase, propName);
    end
    
end
