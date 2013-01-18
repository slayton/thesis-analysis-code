function pf = mwldiodefile(varargin)
%MWLDIODEFILE mwldiodefile constructor
%
%  f=MWLDIODEFILE default constructor, creates a new empty mwldiodefile
%  object.
%
%  f=MWLBOUNDFILE(f) copy constructor
%
%  f=MWLDIODEFILE(filename) open specified mwl diode file in read mode.
%
%  f=MWLDIODEFILE(filename, mode) opens the file in the specified mode
%  ('read', 'write', 'append', 'overwrite').
%
%  f=MWLDIODEFILE(filename, mode, format) specifies the file format
%  ('ascii' or 'binary').
%
%  Example
%    f = mwldiodefile('data.p');
%
%  See also MWLFIXEDRECORDFILE, MWLRECORDFILEBASE, MWLFILEBASE
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin==0
    pf = struct();
    frf = mwlfixedrecordfile();
    pf = class(pf, 'mwldiodefile', frf);
elseif isa(varargin{1}, 'mwldiodefile')
    pf = varargin{1};
else
    frf = mwlfixedrecordfile(varargin{:});
    
    if ismember(frf.mode, {'read', 'append'})
        
        %diode pos file?
        if ~strcmp( getFileType(frf), 'diode')
            error('mwldiodefile:mwldiodefile:invalidFile', 'Not a diode position file')
        end
        
    end
    
    pf = struct();
    
    pf = class(pf, 'mwldiodefile', frf);
end

