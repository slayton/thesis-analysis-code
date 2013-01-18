function retval = mexcode( field )
%MEXCODE mex data type code
%
%  c=MEXCODE(f) returns the mex data type code for all fields in the
%  mwlfield object.
%
%  Example
%    field = mwlfield( 'test', 'char', 1 );
%    mexcode( field )  % will return: 9
%

%  Copyright 2006-2008 Fabian Kloosterman

typestr = mwltypemapping( [field.type], 'code2str');
retval = mwltypemapping( typestr, 'str2mex');
