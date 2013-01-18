function pf = closeHeader(pf)
%CLOSEHEADER write header to disk and reopen file in append mode
%
%  f=CLOSEHEADER(f) closes the header for further modifications, writes
%  the header to disk and reopens the file in append mode.
%
%  Example
%    f = mwldiodefile('test.dat', 'write')
%    f = closeHeader(f);
%
%  See also HEADER
%

%  Copyright 2005-2008 Fabian Kloosterman

hdr = get(pf, 'header');

hdr(1).('File Format') = 'diode';
hdr(1).('Extract type') = 'extended dual diode position';

pf = set(pf, 'header', hdr);

pf.mwlfixedrecordfile = closeHeader(pf.mwlfixedrecordfile);
