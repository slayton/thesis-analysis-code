function display(sh, c)
%DISPLAY show information about subheader
%
%  DISPLAY(f) displays subheader object information
%
%  DISPLAY(f, hidetitle) hides the title. This is used by inherited
%  classes, so that they can show their own title.
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<2 || ~isscalar(c)
    c = 0;
end

if ~(c)
    disp('-- SUBHEADER OBJECT --')
end

np = size(sh.parms, 1);

fieldnames = strjust(str2mat(sh.parms{:,1}), 'left');
fieldvalues = strjust(str2mat(sh.parms{:,2}), 'left');
fieldnames(:, end+1:end+3) = repmat(' : ', np, 1);

disp( [repmat('  ', np, 1) fieldnames fieldvalues])

