function [h, hsize] = loadheader(f)
%LOADHEADER read and parse header from mwl file
%
%  header=LOADHEADER(file) opens the file, reads the header and returns it as
%  a header object. File can be either a file name or a file
%  identifier. If the file is not a mwl file type then an empty header
%  object will be returned.
%
%  [header, headersize]=LOADHEADER returns the size of the header in the
%  file as well.
%
%  Example
%    [hdr, hsz] = loadheader( 'data.dat' );
%
%  See also HEADER
%

%  Copyright 2005-2008 Fabian Kloosterman

[hdr hsize] = readheader(f);

subheaders = processheader(hdr);

if isempty(subheader)
  h = header();
else
  h = header(subheaders);
end


