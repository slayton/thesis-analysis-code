function display(h, c)
%DISPLAY display object information
%
%  DISPLAY(f) displays header object information
%
%  DISPLAY(f, hidetitle) hides the title. This is used by inherited
%  classes, so that they can show their own title.
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<2 || ~isscalar(c)
  c = 0;
end

if ~(c)
  disp('-- HEADER OBJECT --')
end

nsh = len(h);

disp(['  # subheaders: ' num2str(nsh)])

if ~(c) && len(h)>0
  disp(' ')
  disp( 'contains subheaders:' )
  for sh=1:nsh
    display(h.subheaders(sh))
    if sh<nsh
      disp(' ')
    end
  end
end
