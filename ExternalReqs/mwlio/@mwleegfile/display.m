function display(fb, c)
%DISPLAY display object information
%
%  DISPLAY(f) displays mwleegfile object information
%
%  DISPLAY(f, hidetitle) hides the title. This is used by inherited
%  classes, so that they can show their own title.
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<2 || ~isscalar(c)
    c = 0;
end

if ~(c)
    disp('-- EEG FILE OBJECT --')
end

display(fb.mwlfixedrecordfile, 1)


fieldnames = {'n samples', 'n channels'};
fieldvalues = {num2str(fb.nsamples), num2str(fb.nchannels)};

nf = length(fieldnames);

fieldnames = strjust(str2mat(fieldnames), 'left');
fieldvalues = strjust(str2mat(fieldvalues), 'left');
fieldnames(:, end+1:end+3) = repmat(' : ', nf, 1);

disp( [ repmat('  ', nf, 1) fieldnames fieldvalues])
