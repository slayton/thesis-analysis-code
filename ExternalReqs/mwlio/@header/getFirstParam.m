function val=getFirstParam(h,param)
%GETFIRSTPARAM get first available value of parameter
%
%  val=GETFIRSTPARAM(h,param) returns the value of the parameter
%  param from the first subheader in the header h that defines that
%  parameter.

%  Copyright 2008-2008 Fabian Kloosterman

if nargin<2
    help(mfilename)
    return
end

if isempty(param) || ~ischar(param)
  error('header:getFirstParam:invalidParameter', ...
        'Parameter name should be non-empty string')
end

nh = length(h.subheaders);

val = NaN;

b = hasParam( h, param );

idx = find( b, 1, 'first' );

if isempty(idx)
      error('header:getFirstParam', ['Parameter ' param  ' is not defined in any ' ...
                          'subheader'])
else
    val = getParam( h.subheaders(idx), param );
end

