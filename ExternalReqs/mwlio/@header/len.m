function l = len(h)
%LEN return number of subheaders
%
%  L=LEN(h) returns number of subheaders in header
%

%  Copyright 2005-2008 Fabian Kloosterman

l = length(h.subheaders);
