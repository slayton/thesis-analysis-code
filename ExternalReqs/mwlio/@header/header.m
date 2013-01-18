function h = header(varargin)
%HEADER header constructor
%
%  h=HEADER default constructor, creates a new empty header object.
%
%  h=HEADER(h) copy constructor
%
%  h=HEADER(subhdr) creates a new header and initializes it with subheaders.
%
%  h=HEADER(parm1,val1,...) creates a new header an populates it with a
%  subheader with the given parameters.
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin==0
  h.subheaders = [];
  h = class(h, 'header');
elseif isa(varargin{1}, 'header')
  h = varargin{1};
elseif isa(varargin{1}, 'subheader')
  h.subheaders = varargin{1}(:)';
  h = class(h, 'header');
else
  h.subheaders = subheader( varargin{:} );
  h = class(h, 'header' );
end
