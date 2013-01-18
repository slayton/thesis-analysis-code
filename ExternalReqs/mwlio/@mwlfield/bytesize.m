function retval = bytesize( field )
%BYTESIZE return the total field size in bytes
%
%  sz=BYTESIZE(f) returns the size in bytes of all fields in the object
%
%  Example
%    field = mwlfield( 'test', 'short', 2 );
%    bytesize( field )  % will return: 4
%

%  Copyright 2006-2008 Fabian Kloosterman

retval = mwltypemapping( [field.type], 'code2size');
retval = retval .* length( field );
