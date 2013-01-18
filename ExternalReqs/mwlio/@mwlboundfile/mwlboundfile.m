function bf = mwlboundfile(varargin)
%MWLBOUNDFILE mwlboundfile constructor
%
%  f=MWLBOUNDFILE default constructor, creates a new empty mwlboundfile
%  object.
%
%  f=MWLBOUNDFILE(f) copy constructor
%
%  f=MWLBOUNDFILE(filename) open specified mwl boundary file in read
%  mode.
%
%  f=MWLBOUNDFILE(filename, mode) opens the file in the specified mode
%
%  Note: the format of mwl bound files is always ascii.
%
%  Example
%    f = mwlboundfile('test.dat');
%
%  See also MWLOPEN, MWLFILEBASE
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin==0
    bf = struct();
    base = mwlfilebase();
    bf = class(bf, 'mwlboundfile', base);
elseif isa(varargin{1}, 'mwlboundfile')
    bf = varargin{1};
else
    
    if nargin>=2
        base = mwlfilebase(varargin{1:2}, 'ascii');
    else
        base = mwlfilebase(varargin{1}, 'read', 'ascii');
    end
            
    if ismember(base.mode, {'read', 'append'})
    
        if ~strcmp( getFileType(base), 'clbound')
            error('mwlboundfile:mwlboundfile:invalidFile', 'Not a cluster bounds file')
        end
    
    end
    
    if ismember(base.format, {'binary'})
        error('mwlboundfile:mwlboundfile:invalidFormat', 'Bounds file are always ascii!')
    end
    
    bf = class(struct(), 'mwlboundfile', base);
    
end
