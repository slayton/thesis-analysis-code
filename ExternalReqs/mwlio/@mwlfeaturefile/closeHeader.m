function ff = closeHeader(ff)
%CLOSEHEADER write header to disk and reopen file in append mode
%
%  f=CLOSEHEADER(f) closes the header for further modifications, writes
%  the header to disk and reopens the file in append mode.
%
%  Example
%    f = mwlfeaturefile('test.dat', 'write')
%    f = closeHeader(f);
%
%  See also HEADER
%

%  Copyright 2005-2008 Fabian Kloosterman

hdr = get(ff, 'header');

hdr(1).('File Format') = 'feature';

ff = set(ff, 'header', hdr);

ff.mwlfixedrecordfile = closeHeader(ff.mwlfixedrecordfile);
