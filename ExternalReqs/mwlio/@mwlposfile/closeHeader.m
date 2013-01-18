function pf = closeHeader(pf)
%CLOSEHEADER write header to disk and reopen file in append mode
%
%  f=CLOSEHEADER(f) closes the header for further modifications, writes
%  the header to disk and reopens the file in append mode.
%
%  Example
%    f = mwlposfile('test.pos', 'write')
%    f = closeHeader(f);
%
%  See also HEADER
%

%  Copyright 2005-2008 Fabian Kloosterman

hdr = get(pf, 'header');

hdr(1).('File Format') = 'rawpos';

pf = set(pf, 'header', hdr);

pf.mwlrecordfilebase = closeHeader(pf.mwlrecordfilebase);
