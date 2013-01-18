function val = get(wf, propName)
%GET get oject properties
%
%  val=GET(f, property) returns the value of the specified mwlwaveformfile
%  object property. Valid properties are (in addition to those inherited
%  from its base classes):
%  nsamples - number of samples / channel in a waveform
%  nchannels - number of data channels
%
%  See also MWLFIXEDRECORDFILE, MWLRECORDFILEBASE, MWLFILEBASE
%

%  Copyright 2005-2008 Fabian Kloosterman

try
    val = wf.(propName);
catch
    val = get(wf.mwlfixedrecordfile, propName);
end
