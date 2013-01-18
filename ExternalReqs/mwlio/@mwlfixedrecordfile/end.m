function b=end(h,k,n) %#ok
%END end indexing
%
%  b=END(h,k,n) returns the last record index
%

%  Copyright 2005-2008 Fabian Kloosterman

b = get(h, 'nrecords') - 1;
