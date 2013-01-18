function fb = subsasgn(fb,s, b)
%SUBSASGN subscripted assignment for mwlfilebase objects
%
%  f=SUBSASGN(f, subs, value) allows setting property values using the
%  object.property syntax.
%
%  Example
%    f = mwlfilebase('test.dat', 'write');
%    f.format = 'ascii';
%
%  See also MWLFILEBASE/SET
%

%  Copyright 2005-2008 Fabian Kloosterman

switch s.type
case '.'
    
    fb = set(fb, s.subs, b);
    
end

