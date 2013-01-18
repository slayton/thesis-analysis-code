function f = closeHeader(f)
%CLOSEHEADER write header to disk and reopen file in append mode
%
%  f=CLOSEHEADER(f) closes the header for further modifications, writes
%  the header to disk and reopens the file in append mode.
%
%  Example
%    f = mwlfixedrecordfile('test.dat', 'write')
%    f = closeHeader(f);
%
%  See also HEADER
%

%  Copyright 2005-2008 Fabian Kloosterman

hdr = get(f, 'header');

if any(hasParam(hdr, 'File Format'))
    fileformat = getFirstParam(hdr,'File Format');
else
    fileformat = [];
end

if isempty(fileformat)
  hdr(1).('File Format') = 'fixedrecord';
end

f = set(f, 'header', hdr);

f.mwlrecordfilebase = closeHeader(f.mwlrecordfilebase);
