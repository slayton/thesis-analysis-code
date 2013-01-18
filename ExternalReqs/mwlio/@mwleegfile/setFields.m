function ef = setFields(ef)
%SETFIELDS create fields for new eeg file
%
%  f=SETFIELDS(f) sets the fields for a mwl eeg file. This function
%  does not take any other arguments than the file object, since the
%  fields are fixed. An eeg file has the following fields:
%   | field name | field type | field size     |
%   --------------------------------------------
%   | timestamp  | uint32     | 1              |
%   | data       | int16      | nchan*nsamples |
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin>1
  warning('mwleegfile:setFields:invalidFields', ...
          'This file format has fixed fields. Arguments are ignored.')
end

fields = mwlfield({'timestamp', 'data'}, {'uint32', 'int16'}, {1 ef.nchannels*ef.nsamples});

ef.mwlfixedrecordfile = setFields(ef.mwlfixedrecordfile, fields);

fields(2).n = [ef.nchannels ef.nsamples];
ef = setFieldsInterp(ef,fields);