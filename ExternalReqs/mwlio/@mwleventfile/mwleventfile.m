function ef = mwleventfile(varargin)
%MWLEVENTFILE mwleventfile constructor
%
%  f=MWLEVENTFILE default constructor, creates a new empty mwleventfile
%  object.
%
%  f=MWLEVENTFILE(f) copy constructor
%
%  f=MWLEVENTFILE(filename) opens the mwl event file in read mode.
%
%  f=MWLEVENTFILE(filename, mode) opens mwl event file in specified mode
%  ('read', 'write', 'append', 'overwrite').
%
%  f=MWLEVENTFILE(filename, mode, string_size) will set the maximum
%  number of charcters in an event string for a new mwl event file opened
%  in 'write' or 'overwrite' mode (default = 80).
%
%  Example
%    %open file
%    f = mwleventfile( 'events.dat' );
%    %create new file
%    f = mwleventfile( 'events.dat', 'write', 100 );
%
%  See also MWLFIXEDRECORDFILE, MWLRECORDFILEBASE, MWLFILEBASE
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin==0
  ef = struct('string_size', 80);
  frf = mwlfixedrecordfile();
  ef = class(ef, 'mwleventfile', frf);
elseif isa(varargin{1}, 'mwleventfile')
  ef = varargin{1};
else

  frf = mwlfixedrecordfile(varargin{:});
  
  if ismember(frf.mode, {'read', 'append'})
    
    %event file?
    if ~strcmp( getFileType(frf), 'event')
      error('mwleventfile:mwleventfile:invalidFile', 'Invalid event file')
    end
    
    fields = frf.fields;
    names = name(fields);
    if numel(fields) ~=2 || ~strcmp(names(1), 'timestamp') || ~strcmp(names(2), 'string')
      error('mwleventfile:mwleventfile:invalidFile', 'Invalid event file')
    end
    
    ef.string_size = length(fields(2));
    
    flds = get(frf,'fields');
    flds(2).type = 'string';
    frf = setFieldsInterp(frf,flds) ;   
    
  else
    if nargin>2 && isscalar(varargin{3}) && ~ischar(varargin{3}) && varargin{3}>0
      ef.string_size = varargin{3};
    else
      ef.string_size = 80;
    end
  end
  
  ef = class(ef, 'mwleventfile', frf);
end
