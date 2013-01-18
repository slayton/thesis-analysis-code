function retval = length( field )
%LENGTH return the number of elements
%
%  l=LENGTH(f) returns the number of elements for all fields in the
%  mwlfield object
%  
%  Example
%    field = mwlfield( 'test', 'short', 2 );
%    length( field )  % will return: 2
%

%  Copyright 2006-2008 Fabian Kloosterman


retval = zeros( 1, numel(field) );

for k=1:numel(field)

    retval(k) = prod( field(k).n );
    
end
