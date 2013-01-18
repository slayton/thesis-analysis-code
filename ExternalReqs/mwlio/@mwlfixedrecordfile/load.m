function data = load(frf, load_fields, i)
%LOAD load data
%
%  data=LOAD(f) load all records from a mwl fixed record file. The
%  returned data is a structure with all fields present in the file.
%
%  data=LOAD(f, fields) load only the fields specified. The fields
%  argument can be a string or a cell array of strings. If this argument
%  contains 'all', then all fields are loaded.
%
%  data=LOAD(f, fields, indices) load only the records listed in the
%  indices vector. The first record has index 0. Random access is
%  supported for binary files. Only block access is supported for ascii
%  files.
%

%  Copyright 2005-2008 Fabian Kloosterman


fields = get(frf, 'fields_interpretation');
if isempty(fields)
  fields = get(frf,'fields');
end

nfields = numel(fields);

if nargin<2 || isempty(load_fields) || ismember( {'all'}, load_fields )
    load_fields = cellstr(name(fields));
end

field_names = cellstr(name(fields));
[dummy, field_id] = ismember( load_fields,field_names ); %#ok

field_id = field_id( field_id~=0 );
load_fields = field_names( field_id );

if isempty(load_fields)
     data = [];
     return
end
    
for f=1:numel(field_id)
    load_fields{f}( (load_fields{f}==' ' | load_fields{f}=='-') ) = '_';    
end
    
if nargin<3 || isempty(i)
    i = -1; %load all records
end

if ~isa(i, 'double')
    try
        i = double(i);
    catch
        error('mwlfixedrecordfile:load:invalidIndex', 'Invalid index array')
    end
end

if ismember(get(frf, 'format'), {'binary'})
    %check validity of field names
    %and create field definition array

    nrecords = get(frf, 'nrecords');
    
    field_def = mex_fielddef( fields );

    if i==-1
        i = 0:nrecords-1;
    end
    
    if any( i>=nrecords | i<0)
        error('mwlfixedrecordfile:load:invalidIndex', 'Invalid index array (out of bounds)')
    end
    
    if any( fix(i) ~= i )
        error('mwlfixedrecordfile:load:invalidIndex', 'Fractional indices not allowed')
    end 
    
    data = mwlio( fullfile(get(frf,'path'), get(frf, 'filename')), i, field_def(field_id,:), get(frf, 'headersize'), get(frf, 'recordsize'));

    %transpose arrays and construct names

     for f=1:numel(field_id)
       
        %if strcmp(type(fields(f)), 'char') && length(fields(f))>1
        %    data{f} = cellstr( char(data{f})' )';
        %end
        if strcmp(type(fields(f)),'string')
          sz = size( fields(f) );
          nr = size( data{f}, ndims(data{f}) );
          data{f} = deblank( mat2cell( char(data{f}(:,:))', ones(1,nr*prod(sz(2:end))), sz(1) ));
          if numel(sz)>1
            data{f} = reshape(data{f}, [sz(2:end) nr] );
          else
            data{f} = data{f}';
          end
        end
        
     end

    %create structure

    data = cell2struct(data, load_fields);
else %ascii
    
    if (max(diff(i)))>1
        error('mwlfixedrecordfile:load:invalidIndex', 'Can only load contiguous blocks from Ascii file')
    elseif (any(fix(i)~=i) )
        error('mwlfixedrecordfile:load:invalidIndex', 'Fractional indices not allowed')
    else
        
        fid = fopen( fullfile( get(frf, 'path'), get(frf, 'filename') ), 'r' );

        if fid == -1
            error('mwlfixedrecordfile:load:invalidFile','Cannot open file')
        end
        
        skip = ones(nfields,1);
        skip(field_id) = 0;
        
        fmt = formatstr(fields, skip);
               
        %fseek to header offset
        fseek(fid, get(frf, 'headersize'), -1);    
        if i==-1
            data = textscan(fid, fmt, 'delimiter', '\t');
        else
            data = textscan(fid, fmt, length(i), 'headerLines', i(1), ...
                'delimiter', '\t');
        end
    
        outdata = struct();
        ofs = 0;
        
        field_id = sort(field_id);
        
        nrows = numel( data{1} );
        
        for f=1:numel(field_id)
            if strcmp(type(fields(field_id(f))), 'string')
                outdata.(name(fields(field_id(f)))) = data{1 + ofs}';
                sz = size(fields(f));
                if numel(sz)==1
                  sz = 1;
                else
                  sz = sz(2:end);
                end
                outdata.(name(fields(field_id(f)))) = shiftdim( reshape( ...
                    cat( 2, data{(1:prod(sz))+ofs} ), [nrows sz]), 1 );
                ofs = ofs + prod(sz);
            else
                outdata.(name(fields(field_id(f)))) = shiftdim( reshape( ...
                    cell2mat( data( ( 1:length(fields(field_id(f))) ) + ofs ) ), [ nrows size(fields(field_id(f)))] ), 1) ;
                ofs = ofs + length(fields(field_id(f)));
            end
        end
            
        data = outdata;
        
        fclose(fid);
    end
    
end
