function frf = set(frf,varargin)
%SET set object properties and return the updated object
%
%  f=SET(f,prop1,val1,...) sets properties of a mwlfixedrecordfile
%  object and returns the updated object. Properties can only be set for
%  files opened in 'write' or 'overwrite' mode. The following properties
%  can be set (in addition to those inherited from base classes): none
%  


%  Copyright 2005-2008 Fabian Kloosterman

frf.mwlrecordfilebase = set(frf.mwlrecordfilebase, varargin{:});

