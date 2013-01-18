function pf = setFields(pf)
%SETFIELDS create fields for new pos file
%
%  f=SETFIELDS(f) sets the fields for a mwl pos file. This function
%  does not take any other arguments than the file object, since the
%  fields are fixed. An pos file has the following fields (where 'target
%  x' and 'target_y' repeat 0-255 times):
%   | field name | field type | field size |
%   ----------------------------------------
%   | nitems     |  uint8     |  1         |
%   | frame      |  uint8     |  1         |
%   | timestamp  |  uint32    |  1         |
%   | target x   |  int16     |  1         |
%   | target y   |  uint8     |  1         |
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin>1
    warning('mwlposfile:setFields:invalidFields', ...
            'This file format has fixed fields. Arguments are ignored.')
end

fields = mwlfield( {'nitems', 'frame', 'timestamp', 'target x', 'target y'}, {'uint8', 'uint8', 'uint32', 'int16', 'uint8'}, 1);

pf.mwlrecordfilebase = setFields(pf.mwlrecordfilebase, fields);

