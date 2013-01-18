function fb = set(fb,varargin)
%SET set object properties and return the updated object
%
%  f=SET(f,prop1,val1,...) sets properties of a mwlfilebase
%  object and returns the updated object. Properties can only be set for
%  files opened in 'write' or 'overwrite' mode. The following properties
%  can be set:
%  header - a valid header object
%  format - 'ascii' or 'binary'
%
%  Example
%    f = mwlfilebase( 'test.dat', 'write' );
%    f = set(f, 'format', 'ascii');
%
%  See also MWLFILEBASE/GET, HEADER
%

%  Copyright 2005-2008 Fabian Kloosterman

if ismember( fb.mode, {'read', 'append'} )
    error('mwlfilebase:set:invalidMode', ['File is in ' fb.mode ' mode'])
end
    

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
    prop = propertyArgIn{1};
    val = propertyArgIn{2};
    propertyArgIn = propertyArgIn(3:end);
    switch prop
    case 'header'
        if ~isa(val, 'header')
            error('mwlfilebase:set:invalidValue', 'Invalid header')
        else
            fb.header = val;
        end
    case 'binary'
        if ~ismember(val, {'binary', 'ascii'})
            error('mwlfilebase:set:invalidValue', 'Invalid format')
        else
            fb.format = val;
        end            
    otherwise
        error('mwlfilebase:set:invalidProperty', 'Cannot set this property')
    end
end
