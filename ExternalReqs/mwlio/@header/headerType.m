function t=headerType(h)
%HEADERTYPE get header type
%
%  t=HEADERTYPE(h) returns header type of first subheader.
%

%  Copyright 2005-2008 Fabian Kloosterman

if numel(h.subheaders)>0
  t = headerType(h.subheaders(1));
else
  t = 'unknown';
end