function display(fb, c)
%DISPLAY display mwlfilebase object information
%
%  DISPLAY(f) displays mwlfilebase object information
%
%  DISPLAY(f, hidetitle) hides the title. This is used by inherited
%  classes, so that they can show their own title.
%
%  Example
%    f = mwlfilebase( 'test.dat' );
%    %call display explicitly...
%    display(f);
%    %...or implicitly
%    f
%
%  See also MWLFILEBASE
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<2 || ~isscalar(c)
    c = 0;
end

if ~(c)
    disp('-- FILE OBJECT --')
end

fieldnames = {'file name', 'file path', 'file mode', 'file type', 'file size', 'header size'};
fieldvalues = {fb.filename, fb.path, fb.mode, fb.format, [num2str(get(fb,'filesize')) ' bytes'], [num2str(fb.headersize) ' bytes']};

nf = length(fieldnames);

fieldnames = strjust(str2mat(fieldnames), 'left');
fieldvalues = strjust(str2mat(fieldvalues), 'left');
fieldnames(:, end+1:end+3) = repmat(' : ', nf, 1);

disp( [ repmat('  ', nf, 1) fieldnames fieldvalues])

