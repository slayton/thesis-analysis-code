function retval = mex_fielddef( field )
%MEX_FIELDDEF mex type definitions
%
%  fielddef=MEX_FIELDDEF(f) returns the mex type definitions for each
%  field in the mwlfield object.
%


%  Copyright 2006-2008 Fabian Kloosterman

b = num2cell( byteoffset( field ) );
m = num2cell( mexcode( field  ) );
n = {field.n};

retval = [ b(:) m(:) n(:) ];
