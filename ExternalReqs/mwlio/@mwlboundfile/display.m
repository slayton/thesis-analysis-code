function display(bf, c)
%DISPLAY display mwlboundfile object information
%
%  DISPLAY(f) displays mwlboundfile object information
%
%  DISPLAY(f, hidetitle) hides the title. This is used by inherited
%  classes, so that they can show their own title.

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<2 || ~isscalar(c)
    c = 0;
end

if ~(c)
    disp('-- BOUNDS FILE OBJECT --')
end

display(get(bf, 'mwlfilebase'), 1)
