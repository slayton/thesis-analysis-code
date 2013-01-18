function frf = mwlfixedrecordfile(varargin)
%MWLFIXEDRECORDFILE mwlfixedrecordfile constructor
%
%  f=MWLFIXEDRECORDFILE default constructor, creates a new empty
%  mwlfixedrecordfile.
%
%  f=MWLFIXEDRECORDFILE copy constructor
%
%  f=MWLFIXEDRECORDFILE(filename) opens the specified mwl file in read
%  mode.
%
%  f=MWLFIXEDRECORDFILE(filename, mode) opens the file in the specified
%  mode ('read', 'write', 'append', 'overwrite').
%
%  f=MWLFIXEDRECORDFILE(filename, mode, format) specifies the file format
%  ('ascii' or 'binary').
%
%  Example
%    f = mwlfixedrecordfile('test.dat');
%
%  See also MWLRECORDFILEBASE
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin==0
    frf.recordsize = -1;
    rfb = mwlrecordfilebase();
    frf = class(frf, 'mwlfixedrecordfile', rfb);
   
elseif isa(varargin{1}, 'mwlfixedrecordfile')
    frf = varargin{1};
else
    
    rfb = mwlrecordfilebase(varargin{:});
    frf.recordsize = -1;
    
    if ismember(rfb.mode, {'read', 'append'})
        
        fields = get(rfb, 'fields');
    
        if ismember(rfb.format, {'binary'}) %if ascii, recordsize has no meaning and we can't calculate nrecords
        
            frf.recordsize = 0;
            
            frf.recordsize = sum( bytesize(fields) );
        
        end
        
    end
    
    frf = class(frf, 'mwlfixedrecordfile', rfb);
end
