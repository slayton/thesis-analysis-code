function bf = set(bf,varargin)
%SET set object properties and return the updated object
%
%  f=SET(f,prop1,val1,...) sets properties of a mwlboundfile object and
%  returns the updated object. See MWLFILEBASE/SET for more information
%  and a list of valid porperties.
%
%  Example
%    f = mwlboundfile( 'test.dat', 'write');
%    h = header('Date', now);
%    f = set(f, 'header', h);
%
%  See also MWLFILEBASE/SET
%

%  Copyright 2005-2008 Fabian Kloosterman

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
    prop = propertyArgIn{1};
    val = propertyArgIn{2};
    propertyArgIn = propertyArgIn(3:end);
    bf.mwlfilebase = set(bf.mwlfilebase, prop, val);
end
