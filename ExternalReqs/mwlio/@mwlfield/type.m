function retval = type( field )
%TYPE field type
%
%  t=TYPE(f) returns the data types of all fields in the mwlfield object.
%
%  Example
%    field = mwlfield( 'test', 8, 1 );
%    type( field )  % will return: 'uint32'
%

%  Copyright 2006-2008 Fabian Kloosterman

retval = mwltypemapping( [field.type], 'code2str');