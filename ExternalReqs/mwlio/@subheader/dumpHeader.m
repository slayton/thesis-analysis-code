function val = dumpHeader(sh)
%DUMPHEADER dump subheader contents as string
%
%  str=DUMPHEADER(h) dumps subheader contents as a string that can be
%  serialized to disk.
%

%  Copyright 2005-2008 Fabian Kloosterman

val = '';

if size(sh.parms, 1) == 0
    return
end

for p=1:size(sh.parms,1)
    
    if strcmp(sh.parms{p,1}, '')
        %comment
        val = [ val sprintf('%% %s\n', sh.parms{p, 2}) ];
    else
        %parameter
        val = [ val sprintf('%% %s:\t%s\n', sh.parms{p,1}, sh.parms{p,2}) ];
    end
    
end

val = [val sprintf('%%\n')];
