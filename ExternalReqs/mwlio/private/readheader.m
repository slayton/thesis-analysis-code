function [h, hsize] = readheader(f)
%READHEADER read header from file
%
%  h=READHEADER(file) reads the header from a mwl file. File can be
%  either a file name or a file identifier as returned by fopen. The
%  function returns the header in a cell array of strings.
%
%  [h, hsz]=READHEADER(file) also returns the size of the header in
%  bytes.
%
%  Example
%    [h, hsz] = readheader( 'test.dat' );
%
%  See also LOADHEADER
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<1
    error('Invalid file')
end

h = {};
hsize = 0;

magic_start = '%%BEGINHEADER';
magic_end = '%%ENDHEADER';

close_at_end = false;

open_files = fopen('all');

if isscalar(f) && find(open_files == f)
    %f is a file id of an open file
elseif ischar(f)
    %f is a filename
    f = fopen(f, 'r');
    close_at_end = true;
else
    error('readheader:invalidFile', 'Invalid file')
end

if f<0
    error('readheader:invalidFile', 'Can''t open file')
end

%store file position and go to beginning of file
fpos = ftell(f);
fseek(f, 0, 'bof');

%l = fgetl(f); %would take a long time if no text header is present
l = fread(f, [1 numel(magic_start)], 'char=>char');
if ~ischar(l) || ~strcmp(l, magic_start)
    %no recognizable header
    return
end

hsize = numel(magic_start);

nb = length(fgets(f)); %number of bytes for a new line, assume the same for every line in file
hsize = hsize + nb;

while 1
  l = fgetl(f);
  hsize = hsize + length(l) + nb;

  if strcmp(l, magic_end)
    break
  end
  
  %strip off spaces, %, and new lines
  c = find( (l ~= ' ') & (l ~= 0) & (l ~= '%') );
  l = l(min(c) : max(c));

  %store line
  h(end+1) = {l};
   
end

if (close_at_end)
    fclose(f);
else
    fseek(f, fpos, 'bof');
end
