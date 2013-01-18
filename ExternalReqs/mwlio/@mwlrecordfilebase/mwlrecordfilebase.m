function rfb = mwlrecordfilebase(varargin)
%MWLRECORDFILEBASE mwlrecordfilebase constructor
%
%  f=MWLRECORDFILEBASE default constructor, creates a new empty
%  mwlrecordfilebase object.
%
%  f=MWLRECORDFILEBASE(f) copy constructor
%
%  f=MWLRECORDFILEBASE(filename) opens the specified file in read mode.
%
%  f=MWLRECORDFILEBASE(filename, mode) opens file in specified mode
%  ('read', 'write', 'append', 'overwrite').
%
%  f=MWLRECORDFILEBASE(filename, mode, format) specifies file format
%  ('ascii', 'binary').
%
%  See also MWLFILEBASE
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin==0
    rfb.fields = [];
    rfb.fields_interpretation = [];
    bf = mwlfilebase();
    rfb = class(rfb, 'mwlrecordfilebase', bf);
   
elseif isa(varargin{1}, 'mwlrecordfilebase')
    rfb = varargin{1};
else
    
    bf = mwlfilebase(varargin{:});
    
    if ismember(bf.mode, {'read', 'append'})
        hdr = bf.header;
        flds = getFirstParam( hdr, 'Fields');
        if isempty(flds)
            error('mwlrecordfilebase:mwlrecordfilebase:noFields', 'No Fields parameter in header')
        end
       
        rfb.fields = processFields(flds);
    else
        rfb.fields = [];        
    end
    
    rfb.fields_interpretation = [];
    
    rfb = class(rfb, 'mwlrecordfilebase', bf);
end
