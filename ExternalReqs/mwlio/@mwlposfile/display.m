function display(fb, c)
%DISPLAY display object information
%
%  DISPLAY(f) displays mwlposfile object information
%
%  DISPLAY(f, hidetitle) hides the title. This is used by inherited
%  classes, so that they can show their own title.
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<2 || ~isscalar(c)
    c = 0;
end

if ~(c)
    disp('-- RAW POSITION FILE OBJECT --')
end

display(get(fb, 'mwlrecordfilebase'), 1)

fieldnames = {'n records', 'current record', 'current record offset', 'current record timestamp'};
fieldvalues = {num2str(fb.nrecords), num2str(fb.currentrecord), num2str(fb.currentoffset), num2str(fb.currenttimestamp)};

nf = length(fieldnames);

fieldnames = strjust(str2mat(fieldnames), 'left');
fieldvalues = strjust(str2mat(fieldvalues), 'left');
fieldnames(:, end+1:end+3) = repmat(' : ', nf, 1);

disp( [ repmat('  ', nf, 1) fieldnames fieldvalues])

