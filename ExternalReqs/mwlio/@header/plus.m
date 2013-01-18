function h=plus(h,h2)
%PLUS concatenate headers, subheaders or add comments
%
%  h=PLUS(h,h2) concatenates headers h and h2. Either h or h2 can also be
%  a subheader object.
%
%  h=PLUS(h,comment) adds a comment to the first subheader.
%

%  Copyright 2005-2008 Fabian Kloosterman

if isa(h, 'header') && ischar(h2)
  
  h.subheaders(1) = addComment( h.subheaders(1), h2 );
  
else

  %make sure we're dealing with two valid header objects
  try
    h = header(h);
    h2 = header(h2);
    
    %concatenate the subheaders
    h.subheaders = cat(2, h.subheaders, h2.subheaders);
  catch
    
    error('header:plus:invalidArgument', 'Cannot concatenate headers')
    
  end
  
end