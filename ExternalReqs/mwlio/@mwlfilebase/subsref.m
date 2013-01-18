function b = subsref(fb,s)
%SUBSREF subscripted indexing for mwlfilebase objects
%
%  val=SUBSREF(f, subs) allows access to mwlfilebase object properties
%  using the object.property syntax.
%
%  Example
%    f = mwlfilebase( 'test.dat' );
%    filesize = f.filesize;
%
%  See also MWLFILEBASE/GET
%

%  Copyright 2005-2008 Fabian Kloosterman

switch s(1).type
case '.'
    b = get(fb, s(1).subs);
    if numel(s)>1
      b = subsref(b,s(2:end));
    end
end

