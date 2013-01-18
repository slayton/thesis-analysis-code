function retval = processFields(flds)
%PROCESSFIELDS parse fields description
%
%   mwlfield=processFields(field_string) This function will parse the
%   value of the Fields parameter in mwl file headers and return them as
%   a mwlField object.
%


%  Copyright 2005-2008 Fabian Kloosterman

if nargin<1 || ~ischar(flds)
    error('Expecting fieldstring')
end

if ~isempty(strfind(flds, ','))
    %assume new style field descriptors
    
    %split fields on tabs
    
    fields = strread(strtrim(flds), '%s', 'delimiter', '\t');
    
    nfields = length(fields);
    
    field_name = cell(nfields,1);
    field_type = zeros(nfields,1);
    field_size = cell(nfields,1);
        
    for f = 1:nfields
        %get field attributes
        attr = strread(strtrim(fields{f}), '%s', 'delimiter', ',');
        if length(attr)~=4
            error(['Cannot process field: ' fields{f}])
        else
            field_name{f} = attr{1};
            field_type(f) = str2num( attr{2} ); %#ok
            field_size{f} = str2num( attr{4} ); %#ok
        end
        
    end

    retval = mwlfield( field_name, field_type, field_size );
    
else
    %assume old style field descriptor
    rexp = '(?<name>[A-Za-z_]+)(?<size>\[[0-9]+\])?';
    %split on semi colon
    fields = strread(strtrim(flds), '%s', 'delimiter', ';');

    nfields = length(fields);
    
    field_name = cell(nfields,1);
    field_type = cell(nfields,1);
    field_size = zeros(nfields,1);    
    
    for f = 1:nfields
        
        attr = strread(strtrim(fields{f}), '%s', 'delimiter', ' ');
        if length(attr)~=2
            error(['Cannot process field: ' fields{f}])
        else
            matches = regexp(attr{2}, rexp, 'names');
            if ~isempty(matches)
                field_name{f} = matches.name;
                if isfield(matches, 'size')
                    field_size(f) = strread(matches.size, '[%d]');
                else
                    field_size(f) = 1;
                end
            else
                error(['Cannot process field: ' fields{f}])
            end
            
            field_type{f} = attr{1};
            
            %SPECIAL CASE !!!
            if strcmp(field_type{f},'long')
              field_type{f} = 'ulong';
            end
            %END SPECIAL CASE
            
         end
        
    end

    retval = mwlfield( field_name, field_type, field_size );
    
end
    
