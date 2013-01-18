function val = get(fb, propName)
%GET get mwlfilebase properties
%
%  val=GET(f, property) returns the value of the specified mwlfilebase
%  object property. Valid properties are:
%  mode - read/write mode of the object
%  filename - file name
%  path - full path to the file
%  header - header object containing the header of the file
%  headersize - size of the header in bytes
%  filesize - size of the file
%  format - file format
%
%  If the specified property is not any of those listed above, then the
%  header is searched for a parameter with the specified name and its
%  value will be returned.
%
%  Example
%    f = mwlfilebase('test.dat');
%
%    %get the file size
%    get(f, 'filesize');
%
%    %get a parameter from the header
%    get(f, 'Date')
%
%  See also HEADER, MWLFILEBASE/SET, MWLFILEBASE
%

%  Copyright 2005-2008 Fabian Kloosterman


flds = {'mode', 'filename', 'path', 'header', 'headersize', 'format'};

id = find( strcmp(flds, propName) );

if ~isempty(id)
    val = fb.(flds{id});
elseif strcmp( 'filesize', propName )
    if ismember( fb.mode, {'read', 'append'} )
        fid = fopen(fullfile(fb.path, fb.filename), 'rb');
        fseek(fid, 0, 'eof');
        val = ftell(fid);
        fclose(fid);
    else
        val = 0;
    end
else
  try
    val = fb.header(propName);
  catch
    error('mwlfilebase:get:invalidProperty', 'No such property.')
  end
end
    
