function display(fb, c)
%DISPLAY display object information
%
%  DISPLAY(f) displays mwleventfile object information
%
%  DISPLAY(f, hidetitle) hides the title. This is used by inherited
%  classes, so that they can show their own title.
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<2 || ~isscalar(c)
    c = 0;
end

if ~(c)
    disp('-- EVENT FILE OBJECT --')
end

display(fb.mwlfixedrecordfile, 1)


fieldnames = {'string size'};
fieldvalues = {num2str(fb.string_size)};

nf = length(fieldnames);

fieldnames = strjust(str2mat(fieldnames), 'left');
fieldvalues = strjust(str2mat(fieldvalues), 'left');
fieldnames(:, end+1:end+3) = repmat(' : ', nf, 1);

disp( [ repmat('  ', nf, 1) fieldnames fieldvalues])

