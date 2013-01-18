function retval = elementsize( field )
%ELEMENTSIZE return the size of a field element
%
%  elsz=ELEMENTSIZE(f) returns the size of an element in bytes for all
%  fields in the object.
%
%  Example
%    field = mwlfield( 'test', 'char', 1 );
%    elementsize( field )  % will return: 1
%

%  Copyright 2006-2008 Fabian Kloosterman

retval = mwltypemapping( [field.type], 'code2size');
