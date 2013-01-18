function fb = closeHeader(fb)
%CLOSEHEADER write header to disk and reopen file in append mode
%
%  f=CLOSEHEADER(f) closes the header for further modifications, writes
%  the header to disk and reopens the file in append mode.
%
%  Example
%    f=mwlfilebase('test.dat', 'write');
%    h = header( 'MyParameter', 1);
%    f.header = h;
%    f=closeHeader(f);
%
%  See also HEADER, MWLFILEBASE
%

%  Copyright 2005-2008 Fabian Kloosterman


if ismember(fb.mode, {'read', 'append'})
    return
end

hdr = get(fb, 'header');

if ismember(fb.format, 'binary')
  hdr(1).('File type') = 'Binary';
else
  hdr(1).('File type') = 'Ascii';
end

hdr(1).('Program') = 'Matlab mwlIO toolbox';  
hdr(1).('Program version') = 'local';  

fb = set(fb, 'header', hdr);

fid = fopen(fullfile(fb), 'w');

if fid<1
    error('mwlfilebase:closeHeader:FileError', 'Cannot open file for writing')
end

fwrite(fid, dumpHeader(fb.header));

fb.headersize = ftell(fid);
fb.mode = 'append';

fclose(fid);

fb = reopen(fb);
