function ft = getFileType(fb)
%GETFILETYPE return file type based
%
%  filetype=GETFILETYPE(f) returns the file type as determined from the
%  information in the first subheader.
%
%  Example
%    f = mwlfilebase('test.dat');
%    t = getFileType(f);
%
%  See also HEADER/HEADERTYPE
%

%  Copyright 2005-2008 Fabian Kloosterman

if ismember(fb.mode, {'write', 'overwrite'})
    error('mwlfilebase:getHeaderType:invalidMode', 'File is in write mode')
end

ft = headerType(fb.header);
