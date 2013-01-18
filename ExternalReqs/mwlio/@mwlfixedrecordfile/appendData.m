function frf = appendData(frf, data)
%APPENDDATA append new data to fixed record file
%
%  f=APPENDDATA(f, data) append data to fixed record file. Data can be
%  structure with all required fields or a cell array with one cell for
%  each field.
%
%  The data for all fields should have the same number of records. If
%  possible, data is automatically converted to the right data type. If
%  the data type of a field is 'char' and it has more than one element,
%  it is treated as a string. For such a field one can pass in a cell
%  array of strings.

%  Copyright 2005-2008 Fabian Kloosterman

%can only append data in append mode

if nargin<2 || isempty(data)
  return;
end

if ~strcmp( get(frf, 'mode'), 'append' )
    error('mwlfixedrecordfile:appendData:invalidMode', 'Cannot append data if not in append mode')
end

fields = get(frf,'fields_interpretation');
if isempty(fields)
  fields = get(frf, 'fields');
end

nfields = numel(fields);

names = name(fields);


if isstruct(data)
    fldnames=fieldnames(data);
    if ~all(ismember(names,fldnames))
        error('mwlfixedrecordfile:appendData:invalidFields', ...
              'Fields in data structure do not match fields in file')
    end
    
    % convert struct to cell
    data = struct2cell( data );

    %permute cells to the same order as record fields in file
    [dummy, i1] = sort( names ); %#ok
    [dummy, i1] = sort( i1 ); %#ok
    [dummy, i2] = sort( fldnames ); %#ok
    
    data = data(i2(i1));
end

%at this point data should a cell array
if ~iscell(data)
    error('mwlfixedrecordfile:appendData:invalidData', 'Invalid data')
end

%number of cells should be the same as the number of record fields in file
if numel(data)~=nfields
    error('mwlfixedrecordfile:appendData:invalidData', 'Incorrect number of fields in data')
end

%check all record fields
for f =1:nfields

    %check data type and convert
    if strcmp(type(fields(f)),'string')
        if ismember( get(frf,'format'), {'binary'}) %binary file        
            %if ischar(data{f})
            %    data{f} = uint8(data{f});
            %    if size(data{f},2) < length(fields(f))
            %        data{f}(:,(size(data{f},2)+1):length(fields(f))) = 0;
            %    elseif size(data{f},2) > length(fields(f))
            %        data{f} = data{f}(:,1:length(fields(f)));
            %    end
            if iscellstr(data{f}) %size should be:
                                  %[size(fields(f))(2:end) x nrecords]
                %maxlen = length(fields(f));
                %tmp=zeros(numel(data{f}), maxlen, 'uint8');
                %for r=1:numel(data{f})
                %    tmp(r, 1:numel(data{f}{r})) = uint8(data{f}{r});
                %end
                %data{f}=tmp;
                
                sz = size(fields(f));
                data{f} = uint8( char(data{f}{:}) )';
                if size(data{f},1)<sz(1)
                  data{f}(sz(1),1) = 0;
                elseif size(data{f},1)>sz(1)
                  data{f} = data{f}(1:sz(1),:);
                end
            else
                error('mwlfixedrecordfile:appendData:invalidData', ['Invalid data for field ' num2str(f)])
            end
            %data{f} = data{f}';
            %nrows_field = size(data{f}, 2);
            nrows_field=size(data{f},2)./prod(sz(2:end));
        else %ascii
            %if ischar(data{f})
                %convert to cellstr
            %    data{f} = cellstr(data{f});
            if iscellstr(data{f})
                %pass
            else
                error('mwlfixedrecordfile:appendData:invalidData', ['Invalid data for field ' num2str(f)])
            end
            %nrows_field = numel( data{f} );
            sz = size(fields(f));
            nrows_field=numel(data{f})./prod(sz(2:end));
        end
    else
        datatype = matcode(fields(f));
        try
            eval( ['data{f}=' datatype '(data{f});']);
        catch
            error('mwlfixedrecordfile:appendData:invalidData', ['Unable to convert field ' num2str(f) ' to ' datatype])
        end
        nrows_field=-1;
    end
    
    
    %check number of records
    if nrows_field<0
        %number of records in input data;
        nrows_field = numel(data{f}) ./ length(fields(f)); 
    end

    if rem(nrows_field,1)~=0
      error('mwlfixedrecordfile:appendData:invalidData', 'Incorrect number of elements')
    end    
    
    
    if f==1
        nrows = nrows_field;
    elseif nrows~=nrows_field    
        error('mwlfixedrecordfile:appendData:invalidData', 'Incorrect number of rows')
    end
    
end

%write data to file
if ismember( get(frf,'format'), {'binary'})  %binary file
    mwlwrite( fullfile(frf), data, nrows )
else %ascii file
       
    %convert to cell matrix
    fo = 0;
    tmp = {};
    for f = 1:nfields
        if strcmp(type(fields(f)),'string')
            sz = size(fields(f));
            %tmp(1+fo,1:nrows) = data{f}(:)';
            ntmp = prod(sz(2:end));
            tmp((1:ntmp)+fo,1:nrows) = reshape( data{f}, ntmp, nrows );
            fo = fo + ntmp;
        else    
            tmp((1:length(fields(f)))+fo,1:nrows) = mat2cell( reshape( data{f}, length(fields(f)), nrows ), ones(1, length(fields(f))), ones(nrows,1));
            fo = fo + length(fields(f));
        end           
    end        
    
    %save
    fmt = [formatstr(fields, [], '\t', 1) '\n'];
   
    fid = fopen(fullfile(frf), 'a');

    for i=1:nrows
        fprintf(fid, fmt, tmp{:,i});
    end
    
    fclose(fid);
    
end


%reload file
frf = reopen(frf);


return

