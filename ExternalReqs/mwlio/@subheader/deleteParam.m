function sh = deleteParam(sh, parm)
%DELETEPARAM remove parameter from subheader
%
%  sh=DELETEPARAM(sh, param) remove a parameter from a subheader.
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<2
  help(mfilename)
  return
end

if ~ischar(parm) || strcmp(parm, '')
    error('Parameter name should be non-empty string')
end

id = find( strcmp(sh.parms(:,1), parm) );

if (length(id)>1)
    error('subheader:deleteParam:Error', ...
          'Internal error: same parameter present multiple times')
end

if length(id)==1
    sh.parms(id,:) = [];
end

