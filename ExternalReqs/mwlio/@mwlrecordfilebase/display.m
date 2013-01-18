function display(fb, c)
%DISPLAY display object information
%
%  DISPLAY(f) displays mwlrecordfilebase object information
%
%  DISPLAY(f, hidetitle) hides the title. This is used by inherited
%  classes, so that they can show their own title.
%

%  Copyright 2005-2008 Fabian Kloosterman


if nargin<2 || ~isscalar(c)
    c = 0;
end

if ~(c)
    disp('-- RECORD FILE OBJECT --')
end

display(get(fb, 'mwlfilebase'), 1)

display(fb.fields)

if ~isempty(fb.fields_interpretation)
  disp('-- Interpretation of fields: --')
  display(fb.fields_interpretation)
end
