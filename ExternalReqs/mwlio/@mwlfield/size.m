function retval = size( field )
%SIZE field dimensions
%
%  sz=SIZE(f) returns the dimensions of all fields in the mwlfield
%  object.
%
%  Example
%    field = mwlfield( 'test', 'short', 2 );
%    size( field )  % will return: 2
%

%  Copyright 2006-2008 Fabian Kloosterman

if numel(field)==1
    retval = field.n;
else
    retval = { field.n };
end
