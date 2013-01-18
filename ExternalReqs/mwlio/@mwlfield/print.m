function retval = print( field )
%PRINT print mwlfield information in mwl header format
%
%  str=PRINT(f) returns a string with the field definitions that can be
%  used for serializing to disk.
%
%  Example
%    field = mwlfield( 'test', 'double', 1 );
%    f = print( field );
%

%  Copyright 2006-2008 Fabian Kloosterman

n = numel(field);

retval = '';

for k = 1:n
  if field(k).type==-1 || (isscalar(field(k).n) && field(k).n==-1)
    %skip
  else
    if numel(field(k).n) == 1
      retval = [retval sprintf( '%s,%d,%d,%d\t', field(k).name, field(k).type, mwltypemapping(field(k).type, 'code2size'), field(k).n)];
    else
      n_str = [ '[' num2str(field(k).n) ']' ];
      retval = [retval sprintf( '%s,%d,%d,%s\t', field(k).name, field(k).type, mwltypemapping(field(k).type, 'code2size'), n_str)];
    end
  end
end

%remove last tab
retval(end)=[];
