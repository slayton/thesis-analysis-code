function val = dumpHeader(h)
%DUMPHEADER dump header contents as string
%
%  str=DUMPHEADER(h) dumps header contents as a string that can be
%  serialized to disk.
%

%  Copyright 2005-2008 Fabian Kloosterman

val = '';

if isempty(h.subheaders)
    return
end

val = sprintf('%%%%BEGINHEADER\n');

for sh=1:length(h.subheaders)
  val = [val dumpHeader(h.subheaders(sh))];
end

val = [val sprintf('%%%%ENDHEADER\n')];


