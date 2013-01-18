function h=deleteComments(h,ind)
%DELETECOMMENTS delete all comments from header
%
%  h=deleteComments(h) delete all comments from all subheaders in header
%  h.
%
%  h=deletComments(h,i) delete all comments from subheaders i in header
%  h.
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<2
  for k=1:length(h.subheaders)
    h.subheaders(k) = deleteComments( h.subheaders(k) );
  end
else
  if ~isnumeric(ind) || any( ind<1 | ind>length(h.subheaders))
    error('header:deleteComments:invalidIndex', 'Invalid index')
  else
    for k=1:numel(ind)
      h.subheaders(ind(k)) = deleteComments( h.subheaders(ind(k)));
    end
  end
end