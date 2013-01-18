function varargout=getComments(h,ind)
%GETCOMMENTS get comments from header
%
%  [c1,c2,...]=getComments(h) returns all comments for all subheaders in
%  header h.
%
%  [c1,c2,...]=getComments(h,i) returns all comments for selected
%  subheaders (with indices i) in header h.
%

%  Copyright 2005-2008 Fabian Kloosterman%


nh = numel(h.subheaders);

if nargin<2
  varargout = cell(nh,1);
  for k=1:nh
    varargout{k} = getComments(h.subheaders(k));
  end
else
  if ~isnumeric(ind) || any( ind<1 | ind>nh)
    error('header:getComments:invalidIndex', 'Invalid index')
  else
    for k=1:numel(ind)
      varargout{k} = getComments( h.subheaders(ind(k)));
    end
  end
end  