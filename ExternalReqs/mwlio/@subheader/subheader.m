function sh = subheader(varargin)
%SUBHEADER subheader constructor
%
%  sh=SUBHEADER default constructor, creates a new empty subheader
%  object.
%
%  sh=SUBHEADER(sh) copy constructor
%


%  Copyright 2005-2008 Fabian Kloosterman


if nargin==0
    sh.parms = cell(0,2);
    sh = class(sh, 'subheader');
elseif isa(varargin{1}, 'subheader')
    sh = varargin{1};
else
  
  sh.parms = cell(0,2);  
  
  if isstruct(varargin{1})
    
    sh.parms(:,1) = fieldnames(varargin{1});
    
    for k=1:size(sh.parms,1)
      sh.parms{k,2} = checkvalue(varargin{1}.(sh.parms{k,1}));
    end
    
  else
    
    for k=1:2:length(varargin)
      if ~ischar(varargin{k})
        error('subheader:subheader:invalidArguments', 'Invalid arguments');
      end
      sh.parms{end+1,1} = varargin{k};
      sh.parms{end,2} = checkvalue(varargin{k+1});
    end
    
  end
    
  sh = class(sh, 'subheader');  
  
end




