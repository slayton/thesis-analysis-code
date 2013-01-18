function b = hasParam(sh,param)
%HASPARAM test for presence of parameter in subheader
%
%  b=HASPARAM(sh,param) return 1 if subheader defines parameter
%  param and 0 otherwise.
%

%  Copyright 2008-2008 Fabian Kloosterman

if nargin<2
    help(mfilename)
    return
end

if isempty(param) || (~ischar(param) && ~iscellstr(param))
  error('subheader:hasParam:invalidParameter', ...
        ['Parameter name should be non-empty string or cell array of ' ...
         'strings'])
end

if ischar(param)
    
    b = any( strcmp(sh.parms(:,1), param) );
    
else
    
    n = numel(param);
    b=false(1,n);
    
    for k=1:n
        
        b(k) = any( strcmp(sh.parms(:,1), param{k} ) );
        
    end
    
end

        
        