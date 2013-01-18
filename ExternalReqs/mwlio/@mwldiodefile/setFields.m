function pf = setFields(pf)
%SETFIELDS create fields for new record file
%
%  f=SETFIELDS(f) sets the fields for a mwl diode file. This function
%  does not take any other arguments than the file object, since the
%  fields are fixed. A diode file has the following fields:
%   | field name | field type | field size |
%   ----------------------------------------
%   | timestamp  | uint32     | 1          |
%   | xfront     | int16      | 1          |
%   | xback      | int16      | 1          |
%   | yfront     | int16      | 1          |
%   | yback      | int16      | 1          |
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin>1
    warning('mwldiodefile:setFields:invalidFields', ...
            'This file format has fixed fields. Arguments are ignored.')
end

  fields = mwlfield( {'timestamp', 'xfront', 'yfront', 'xback', 'yback'}, {'uint32', 'int16', 'int16', 'int16', 'int16'}, 1);

pf.mwlfixedrecordfile = setFields(pf.mwlfixedrecordfile, fields);
