function retval = code( field )
%CODE return the field type code
%
%  c=CODE(f) returns the data type codes of all fields in the object.
%
%  Example
%    field = mwlfield( 'test', 'char', 1 );
%    code( field )  % will return: 1
%

%  Copyright 2006-2008 Fabian Kloosterman

retval = [field.type];
