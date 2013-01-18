function rfb = closeHeader(rfb)
%CLOSEHEADER write header to disk and reopen file in append mode
%
%  f=CLOSEHEADER(f) closes the header for further modifications, writes
%  the header to disk and reopens the file in append mode.
%
%  See also HEADER
%

%  Copyright 2005-2008 Fabian Kloosterman


if nargout~=1
  warning('mwlrecordfilebase:closeHeader:noOutput', ...
          'It is safer to provide an output argument. Aborted.')
  return;
end
  
fldstr = print( rfb.fields );

hdr = get(rfb, 'header');

hdr(1).('Fields') = fldstr;

rfb = set(rfb, 'header', hdr);

rfb.mwlfilebase = closeHeader(rfb.mwlfilebase);
