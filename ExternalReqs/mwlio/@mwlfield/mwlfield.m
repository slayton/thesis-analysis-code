function field = mwlfield(varargin)
%MWLFIELD mwlfield constructor
%
%  f=MWLFIELD default constructor, creates new empty mwlfield object.
%
%  f=MWLFIELD(f) copy constructor
%
%  f=MWLFIELD(name) creates a new mwlfield object with a set of fields
%  with the specified names. Names can be specified as a string or a cell
%  array of strings.
%
%  f=MWLFIELD(name, type) specifies the data type of the fields. The type
%  can be specified as either a string, a cell array of strings or a type
%  code (default = 'int16').
%
%  f=MWLFIELD(name, type, size) specifies the dimensions of each
%  field. Dimensions can be specified as a vector or as a cell array of
%  vectors (default = 1).
%
%  Example
%    f = mwlfield( {'test', 'test2'}, {'short', 'double'}, {2, [2 4 6]} );
%
%  See also MWLTYPEMAPPING
%

%  Copyright 2006-2008 Fabian Kloosterman

if nargin==0
    field = struct('name', '', 'type', -1, 'n', -1);
    field = class( field, 'mwlfield');
elseif isa(varargin{1}, 'mwlfield')
    field = varargin{1};
else
    arg_name = varargin{1};
    if ischar(arg_name)
        n = 1;
        field.name =  varargin{1};
    elseif iscellstr(arg_name)
        n = numel(arg_name);
        [field(1:n).name] = deal( arg_name{:} );
    else
        error('mwlfield:mwlfield:invalidNames', 'Invalid field names')
    end    
    
    if nargin>1
      arg_type = varargin{2};
      if ischar(arg_type)
        arg_type = num2cell( mwltypemapping(arg_type, 'str2code') );
        [field(1:n).type] = deal( arg_type{:} );
      elseif iscellstr(arg_type) && numel(arg_type)==n
        arg_type = num2cell( mwltypemapping(arg_type, 'str2code') );
        [field(1:n).type] = deal( arg_type{:} );
      elseif isnumeric(arg_type) && ~any( arg_type<1 ) && ~any( arg_type>13 ) && ( numel(arg_type)==1 || numel(arg_type)==n )
        arg_type = num2cell( fix( arg_type ) );
        [field(1:n).type] = deal( arg_type{:} );
      else
        error('mwlfield:mwlfield:invalidType', 'Invalid data type')
      end
    else
      [field.type] = deal(2); %int16
    end
    
    if nargin>2
        if isnumeric(varargin{3}) && all(varargin{3}>0)
            [field.n] = deal( fix(varargin{3}) );
        elseif iscell(varargin{3}) && numel(varargin{3}) == n            
            [field(1:n).n] = deal( varargin{3}{:} );
            %TODO check number of elements!
        else
            error('mwlfield:mwlfield:invalidType', 'Invalid field size')
        end
    else
        [field.n] = deal(1);
    end
    
    field = class(field, 'mwlfield');
end
