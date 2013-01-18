function ef = setFields(ef)
%SETFIELDS create fields for new event file
%
%  f=SETFIELDS(f) sets the fields for a mwl event file. This function
%  does not take any other arguments than the file object, since the
%  fields are fixed. An event file has the following fields:
%   | field name | field type | field size   |
%   ------------------------------------------
%   | timestamp  | uint32     | 1            |
%   | string     | char       | string_size  |
%  The 'string' field is reinterpreted as a string data type.
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin>1
    warning('mwleventfile:setFields:invalidFields', ...
            'This file format has fixed fields. Arguments are ignored.')
end

fields = mwlfield({'timestamp', 'string'}, {'uint32', 'char'}, {1 ef.string_size});

ef.mwlfixedrecordfile = setFields(ef.mwlfixedrecordfile, fields);

fields(2).type = 'string';
ef = setFieldsInterp(ef,fields);