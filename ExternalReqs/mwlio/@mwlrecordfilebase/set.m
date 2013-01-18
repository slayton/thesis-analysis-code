function rfb = set(rfb,varargin)
%SET set object properties and return the updated object
%
%  f=SET(f, prop1, val1, ...) sets the properties of a mwlrecordfilebase
%  object and returns the updated object. Properties can only be set for
%  files opened in 'write' or 'overwrite' mode. The following properties
%  can be set (in addition to those inherited from its base classes):
%  fields - record field descriptions (mwlfield object)
%

%  Copyright 2005-2008 Fabian Kloosterman

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
    prop = propertyArgIn{1};
    val = propertyArgIn{2};
    propertyArgIn = propertyArgIn(3:end);
    switch prop
        case 'fields'
            rfb = setFields(rfb, val);
        otherwise
            rfb.mwlfilebase = set(rfb.mwlfilebase, prop, val);
    end
end
