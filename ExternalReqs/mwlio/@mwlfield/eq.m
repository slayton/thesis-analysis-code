function e = eq( A, B )
%EQ equality test for mwlfield objects
%
%  b=EQ(f1,f2) test whether two mwlfield objects are identical.
%
%  Example
%    f1 = mwlfield( 'test', 'short', 1 );
%    f2 = mwlfield( 'test', 'short', 2 );
%    f1 == f2 %returns 0
%

%  Copyright 2006-2008 Fabian Kloosterman

if ~isa(A, 'mwlfield') || ~isa(B, 'mwlfield')
    e = 0;
elseif numel(A) ~= numel(B)
    e = 0;
else
    for k = 1:numel(A)
        if strcmp(A(k).name, B(k).name) && A(k).type == B(k).type && numel(A(k).n) == numel(B(k).n) && all( A(k).n == B(k).n )
            e(k) = 1;
        else
            e(k) = 0;
        end
    end
end

