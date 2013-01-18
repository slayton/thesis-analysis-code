function b = hasParam(h,param)
%HASPARAM test for presence of parameter in header
%
%  b=HASPARAM(h,param) return 1 for each subheader in header h that
%  define parameter param and 0 otherwise.
%

%  Copyright 2008-2008 Fabian Kloosterman

if nargin<2
    help(mfilename)
    return
end

if isempty(param) || (~ischar(param) && ~iscellstr(param))
  error('header:hasParam:invalidParameter', ...
        ['Parameter name should be non-empty string or cell array of ' ...
         'strings'])
end

nh = length(h.subheaders);

if ischar(param)
    b = false(nh,1);
else
    b = false(nh, numel(param));
end

for k=1:nh
    
    b(k,:) = hasParam( h.subheaders(k), param );
    
end
