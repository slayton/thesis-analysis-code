function fmtstr = formatstr(fields, skip, delimiter, fmttype)
%FORMATSTR convert fields to format string for use with textscan and fprintf
%
%  str=FORMATSTR(f) returns a format string that can be used to read data
%  using textscan function.
%
%  str=FORMATSTR(f, skip) indicates which fields should be skipped. Skip
%  should be a vector with 0 for reach field to be skipped and 1
%  otherwise.
%
%  str=FORMATSTR(f, skip, delimiter) specifies an optional delimiter to
%  be used between field format strings (default ='').
%
%  str=FORMATSTR(f, skip, delimiter, formattype) indicates whether the
%  target is textscan (0) or fprintf (1).
%

%  Copyright 2005-2008 Fabian Kloosterman

nfields = numel(fields);

if nargin<2 || isempty(skip)
    skip = zeros(nfields,1);
elseif ~isnumeric(skip) || numel(skip) ~= nfields
    error('mwlfield:formatstr:invalidArgument', 'Invalid skip vector')
end

if nargin<3 || isempty(delimiter)
    delimiter = '';
end

if nargin<4 || isempty(fmttype) || fmttype==0
  %mapping = {'u8', 'd16', 'd32', 'f', 'f', 's', 's', 'd32'};
  mapping = {'u8', 'd16', 'd32', 'f', 'f', 's', 's', 'd32', 'd8', ...
             's', 'u16', 'd64', 'u64'};    
else
    mapping = {'d', 'd', 'd', 'f', 'f', 's', 's', 'd', 'd', 's', ...
               'd', 'd', 'd'};
end

fmtstr = '';

field_type = code( fields );

for f=1:nfields
    
    if skip(f)
        fmt =  '%*';
    else
        fmt = '%';
    end
    
    %if field_type(f)==1 %char
    %    if length(fields(f))>1 %treat as string
    %        fmt = [fmt 's'];
    %    else
    %        fmt = [fmt mapping{field_type(f)}];
    %    end
    if field_type(f)>=1 && field_type(f)<=13
        fmt = [fmt mapping{field_type(f)}];
    else
        error('mwlfield:formatstr:invalidType', 'Incorrect field type')
    end

    if field_type(f)~=10 %string
        fmt2='';
    
        for i = 1:length(fields(f))
            fmt2 = [fmt2 fmt delimiter];
        end
    
        fmtstr = [fmtstr fmt2];
    else
      fmt2='';
      sz = size(fields(f));
      for i=1:prod(sz(2:end))
        fmt2 = [fmt2 fmt delimiter];
      end
      fmtstr = [fmtstr fmt2];
    end
    
end
