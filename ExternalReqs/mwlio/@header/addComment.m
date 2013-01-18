function h = addComment(h, varargin)
%ADDCOMMENT add comments to header
%
%  h=ADDCOMMENT(h,comment1,comment2,...) add comments to all subheaders
%  in the header h.
%
%  h=ADDCOMMENT(h,i,comment1,commnt2,...) add comments to subset of
%  subheaders (with indices i) to header h.
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<2 || (nargin==2 && ~ischar(varargin{1}))
  help(mfilename)
  return
end

if isnumeric(varargin{1}) %subheader index
  
  if any(varargin{1}<1 | varargin{1}> numel(h.subheaders))
    error('header:addComment:invalidIndex', 'Invalid index')
  end
  
  for j=1:numel(varargin{1})
  
    for k=2:numel(varargin)
    
      h.subheaders(varargin{1}(j)) = addComment( h.subheaders(varargin{1}(j)), ...
                                                 varargin{k});
    end
    
  end
  
else
  
  for k=1:numel(varargin)
    
    h.subheaders(1) = addComment( h.subheaders(1), ...
                                  varargin{k});
  end
  
end