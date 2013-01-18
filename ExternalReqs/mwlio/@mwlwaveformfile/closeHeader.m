function wf = closeHeader(wf)
%CLOSEHEADER write header to disk and reopen file in append mode
%
%  f=CLOSEHEADER(f) closes the header for further modifications, writes
%  the header to disk and reopens the file in append mode.
%
%  Example
%    f = mwlwaveformfile('test.dat', 'write')
%    f = closeHeader(f);
%
%  See also HEADER
%

%  Copyright 2005-2008 Fabian Kloosterman

hdr = get(wf, 'header');

hdr(1).('File Format') = 'waveform';
hdr(1).('nchannels') = wf.nchannels;

wf = set(wf, 'header', hdr);

wf.mwlfixedrecordfile = closeHeader(wf.mwlfixedrecordfile);
