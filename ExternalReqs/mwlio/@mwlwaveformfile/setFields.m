function wf = setFields(wf)
%SETFIELDS create fields for new waveform file
%
%  f=SETFIELDS(f) sets the fields for a mwl waveform file. This function
%  does not take any other arguments than the file object, since the
%  fields are fixed. An eeg file has the following fields:
%   | field name | field type | field size     |
%   --------------------------------------------
%   | timestamp  | uint32     | 1              |
%   | waveform   | int16      | nchan*nsamples |
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin>1
    warning('mwlwaveformfile:mwleaveformfile:invalidFIelds', ...
            'This file format has fixed fields. Arguments are ignored.')
end

fields = mwlfield({'timestamp', 'waveform'}, {'uint32', 'int16'}, {1 wf.nchannels*wf.nsamples});

wf.mwlfixedrecordfile = setFields(wf.mwlfixedrecordfile, fields);

fields(2).n = [wf.nchannels wf.nsamples];
wf = setFieldsInterp(wf,fields); 