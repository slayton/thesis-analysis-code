function [tf, loc] = ismember( A, B )
%ISMEMBER true if set member
%
%  b=ISMEMBER(f1,f2) returns whether field names of object f2 are
%  members of the field names of object f1.
%
%  b=ISMEMBER(name,f) for a string or a cell array of strings, returns if
%  they are member of the field names of object f.
%
%  b=ISMEMBER(f,name) for a string or a cell array of strings, returns if
%  the field names of object f are members of name.
%
%  [b,loc]=ISMEMBER(A,B) returns the index array loc which contains the
%  highest absolute index in B for each element in A which is member of B
%  and 0 if there is no such index.
%
%  Example
%    field = mwlfield( {'test', 'dummy'} );
%    ismember( field, {'dummy', 'test2', 'test3'} )  %will return: [0 1]
%

%  Copyright 2006-2008 Fabian Kloosterman

if isa(A, 'mwlfield')
    A = {A.name};
end

if isa(B, 'mwlfield')
    B = {B.name};
end

[tf, loc] = ismember( A, B );
