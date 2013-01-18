function retval = name( field )
%NAME field names
%
%  n=NAME(f) returns the names of all fields in the mwlfield object.
%
%  Example
%    field = mwlfield( 'test', 8, 1 );
%    name( field )  % will return: 'test'
%

%  Copyright 2006-2008 Fabian Kloosterman

retval = {field.name};

if numel(retval)==1
    retval = retval{1};
end
