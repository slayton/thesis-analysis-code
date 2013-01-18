function makesources(target)
%MAKESOURCES compile mex files
%
%  MAKESOURCES compiles all source file
%
%  MAKESOURCES(target) compiles target source files only. Target can be
%  either a string or a cell array of strings to specifiy multiple
%  targets. 
%


if nargin<1 || isempty(target)
     target = {'all'};
end

if ~iscell(target)
     target = {target};
end

if ~iscellstr(target)
     error('makesources:invalidTarget', 'Target must be a string or a cell array of strings')
end

target = lower(target);

cfiles = {'findrecord', 'mwlio', 'mwlwrite', 'poscountrecords', 'posfindrecord', 'posfindtimerange', 'posloadrecordrange'};

for i=1:length(cfiles)
     if (ismember(cfiles{i}, target) || ismember('all', target))
         eval(['mex -Iinclude src/' cfiles{i} '.c'])
     end
end  
