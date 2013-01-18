function val = getParam(sh, parm)
%GETPARAM get value of subheader parameter
%
%  val=GETPARAM(h, param) returns value of a subheader parameter.
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<2
  help(mfilename)
  return
end

if ~ischar(parm) || strcmp(parm, '')
  error('subheader:getParam:invalidParameter', ...
        'Parameter name should be non-empty string')
end

id = find( strcmp(sh.parms(:,1), parm) );

if (length(id)>1)
  error('subheader:getParam:Error', ...
        'Internal error: same parameter present multiple times')
end

if isempty(id)
  error('subheader:getParam:Error',...
        'Internal error: requested parameter does not exist');
else
  val = sh.parms{id,2};
end

