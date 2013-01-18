function ff = mwlfeaturefile(varargin)
%MWLFEATUREFILE mwlfeaturefile constructor
%
%  f=MWLFEATUREFILE default constructor, creates a new empty
%  mwlfeaturefile object.
%
%  f=MWLFEATUREFILE(f) copy constructor
%
%  f=MWLFEATUREFILE(filename) opens the specified mwl feature file in
%  read mode.
%
%  f=MWLFEATUREFILE(filename, mode) opens the mwl feature file in the
%  specified mode ('read', 'write', 'append', 'overwrite').
%
%  f=MWLFEATUREFILE(filename, mode, format) specifies the file format
%  ('ascii' or 'binary').
%
%  Example
%    f = mwlfeaturefile('data.pxyabw');
%
%  See also MWLFIXEDRECORDFILE, MWLRECORDFILEBASE, MWLFILEBASE
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin==0
    ff = struct();
    frf = mwlfixedrecordfile();
    ff = class(ff, 'mwlfeaturefile', frf);
elseif isa(varargin{1}, 'mwlfeaturefile')
    ff = varargin{1};
else
    frf = mwlfixedrecordfile(varargin{:});
    
    if ismember(frf.mode, {'read', 'append'})
        
        %feature file?
        if ~strcmp( getFileType(frf), 'feature')
            error('mwlfeaturefile:mwlfeaturefile:invalidFile', 'Invalid feature file')
        end
        
    end
    
    ff = struct();
    
    ff = class(ff, 'mwlfeaturefile', frf);
end

