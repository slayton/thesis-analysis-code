function retval = matcode( field )
%MATCODE return matlab type code
%
%  c=MATCODE(f) returns the matlab data type code for all fields in the
%  mwlfield object.
%
%  Example
%    field = mwlfield( 'test', 'char', 1 );
%    matcode( field )  % will return: 'uint8'
%

%  Copyright 2006-2008 Fabian Kloosterman

typestr = mwltypemapping( [field.type], 'code2str');
retval = mwltypemapping( typestr, 'str2mat');
