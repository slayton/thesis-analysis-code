function retval = byteoffset( field )
%BYTEOFFSET byte offsets for fields
%
%  offset=BYTEOFFSET(f) returns the offset in bytes of all fields in the
%  object.
%
%  Example
%    field = mwlfield( {'test', 'dummy'}, {'short', 'short'}, 1 );
%    b = byteoffset( field );  %will return: [0 2]
%

%  Copyright 2006-2008 Fabian Kloosterman

retval = bytesize( field );
retval = cumsum( [0 retval(1:end-1)] );
