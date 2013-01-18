function fb = mwlfilebase(varargin)
%MWLFILEBASE mwlfilebase constructor
%
%  f=MWLFILEBASE default constructor, creates a new empty mwlfilebase
%  object.
%
%  f=MWLFILEBASE(f) copy constructor
%
%  f=MWLFILEBASE(filename) opens the specified mwl file in read mode.
%
%  f=MWLFILEBASE(filename, mode) opens the mwl file in the specified
%  mode. Valid modes are:
%  read - File is opened in read mode and no new data can be written to
%  this file.
%  append - Data can read from the file and appended to the end.
%  write - A new file is created. It is an error to try to create an
%  already existing file.
%  overwrite - A new file is created. If the file already exist it will
%  be overwritten.
%
%  f=MWLFILEBASE(filename, mode, format) sets the format of a new file to
%  either 'ascii' or 'binary' (default). The format argument is only used
%  if mode is either 'write or 'overwrite'.
%
%  Example
%    %open existing mwl file
%    f = mwlfilebase('test.dat');
%
%    %create a new file
%    f = mwlfilebase('test.dat', 'write');
%
%  See also MWLFILEBASE/GET, MWLFILEBASE/SET
%

%  Copyright 2005-2008 Fabian Kloosterman

fb = struct( 'mode', '', 'filename', '', 'path', '', 'header', [], ...
             'headersize', 0, 'format', '');

if nargin==0
    fb.mode = '';       % read, append, write or overwrite
    fb.filename = '';   % name of the file + extension
    fb.path = '';       % path to the file
    fb.header = header();   % header obj
    fb.headersize = 0;      % size of the header
    %fb.filesize = 0;        % size of the file
    fb.format = 'binary';   % binary or ascii file
    fb = class(fb, 'mwlfilebase');
elseif isa(varargin{1}, 'mwlfilebase')
    fb = varargin{1};
elseif nargin>3
    error('mwlfilebase:mwlfilebase:invalidArguments', 'Too many arguments')
else
    % check input parameters
    if ~ischar( varargin{1})
        error('mwlfilebase:mwlfilebase:invalidArguments','Invalid file name')
    else
        filename = varargin{1};
    end
    if nargin>1 && ~isempty(varargin{2})
        mode = varargin{2};
        if ~ismember(mode, {'read', 'append', 'write', 'overwrite'})
            error('mwlfilebase:mwlfilebase:invalidArguments','Invalid mode parameter');
        end
    else
        mode = 'read';
    end
    if nargin>2 && ismember( mode, {'write', 'overwrite'} )
        isbin = varargin{3};
        if ~ismember(isbin, {'binary', 'ascii'})
            error('mwlfilebae:mwlfilebase:invalidArguments','Invalid format parameter')
        end
    else
        isbin = 'binary';
    end
    
   
    %initialize
    fb.mode = mode;
    fb.headersize = 0;
    fb.header = header();
    %fb.filesize = 0;

    % if file is opened in read mode
    if ismember(fb.mode, {'read', 'append'})

        [fb.path, fb.filename, ext] = fileparts(fullpath(filename));
        
        fb.format = ''; %will be set later
        fb.filename = [fb.filename ext];
    
        fid = fopen(fullfile(fb.path, fb.filename), 'rb');
    
        if fid == -1
            error('mwlfilebase:mwlfilebase:invalidFile',['Cannot open file: ' fullfile(fb.path, fb.filename)])
        end
    
        [fb.header fb.headersize] = loadheader(fid);
        
        if fb.headersize == 0
            fclose(fid);
            error('mwlfilebase:mwlfilebase:invalidFile','No valid header in file')
        end

        if any( hasParam(fb.header, 'File type') )
            fileformat = getFirstParam( fb.header, 'File type' );
        else    
            fileformat = [];
        end
    
        if isempty(fileformat) || strcmp(fileformat, 'Binary')
            fb.format = 'binary';
        else
            fb.format = 'ascii';
        end
        
        fseek(fid, 0, 'eof');
        %fb.filesize = ftell(fid);
        fseek(fid, fb.headersize, 'bof');
                    
    else % if file is opened in write mode
        if exist(filename, 'file') && ismember(fb.mode, {'write'})
            error('mwlfilebase:mwlfilebase:invalidFile','Error creating new file: file already exists')
        end
        
        fid = fopen(filename, 'w');
        
        if fid == -1
            error('mwlfilebase:mwlfilebase:invalidFile','Cannot create file')
        end
        
        [fb.path, fb.filename, ext] = fileparts(filename);
        fb.filename = [fb.filename ext];
        fb.format = isbin;

    end
    
    fclose(fid);
    
    fb = class(fb, 'mwlfilebase');
    
end
