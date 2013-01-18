function pf = mwlposfile(varargin)
%MWLPOSFILE mwlposfile constructor
%
%  f=MWLPOSFILE default constructor, creates a new empty mwlposfile
%  object.
%
%  f=MWLPOSFILE(f) copy constructor
%
%  f=MWLPOSFILE(filename) opens the specified mwl pos file in read mode.
%
%  f=MWLPOSFILE(filename, mode) opens the file in the specified mode
%  ('read', 'write', 'append', 'overwrite').
%
%  Note: Only binary mwl pos files are supported
%
%  See also MWLRECORDFILEBASE
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin==0
    pf = struct('currentrecord', 0, 'currentoffset', 0, 'currenttimestamp', 0, 'nrecords', 0);
    rfb = mwlrecordfilebase();
    pf = class(pf, 'mwlposfile', rfb);
elseif isa(varargin{1}, 'mwlposfile')
    pf = varargin{1};
else
    rfb = mwlrecordfilebase(varargin{:});
    
    if ~ismember( rfb.format, {'binary'} )
        error('mwlposfile:mwlposfile:invalidFormat', 'Ascii pos files are not supported.')
    end
    
     pf.nrecords = 0;
     pf.currentrecord = 0;
     pf.currenttimestamp = 0;
     pf.currentoffset = 0;    
    
     if ismember( rfb.mode, {'read', 'append'})
        
        %rawpos file?
        if ~strcmp( getFileType(rfb), 'rawpos')
            error('mwlposfile:mwlposfile:invalidFile', ...
                  'Invalid raw position file')
        end
        
        %check fields
        fields = mwlfield( {'nitems', 'frame', 'timestamp', 'target x', 'target y'}, {'uint8', 'uint8', 'uint32', 'int16', 'uint8'}, 1);
        if ~all( fields==rfb.fields )
            error('mwlposfile:mwlposfile:invalidFile', ...
                  'Invalid raw position file')
        end
     
        pf.nrecords = posfindrecord( fullfile( get(rfb, 'path'), get(rfb, 'filename')), get(rfb, 'headersize'), Inf );
        pf.currentoffset = get(rfb, 'headersize');

     end
     
     pf = class(pf, 'mwlposfile', rfb);
     
     if ismember( rfb.mode, {'read', 'append'})
        pf = setCurrentRecord(pf, 0);
     end
     
end

