function data = loadrange(frf, varargin)
%LOADRANGE load data from mwl fixed record file
%
%  data=LOADRANGE(f, 
%  Syntax
%
%      data = loadrange( f [, fields [, range, range_field]] )
%
%  Description
%
%    This method loads (part of) the data from a fixed record file f. The
%    fields parameter can be a string or cell array of strings indicating
%    which fields to load from the file. In case fields = 'all', then all
%    fields will be loaded (this is also the default if no fields parameter
%    is specified). The range parameter is a two-element vector specifying
%    the first and last record indices of the data range to load (default =
%    all records). The range_field parameter can be set to a field to use as
%    the source for the range, rather than record indices. This method only
%    reads binary files.
%

%  Copyright 2005-2008 Fabian Kloosterman


if ismember(get(frf, 'format'), {'ascii'})
    error('mwlfixedrecordfile:loadrange:invalidFormat', ...
          'This function not implemented for ascii files');
end

if nargin<2 || isempty(varargin{1})
  varargin{1} = 'all';
end

if nargin<3 || isempty(varargin{2})
    irange = [0 get(frf,'nrecords')-1 ];
elseif ~isnumeric(varargin{2}) || numel(varargin{2})~=2
    error('mwlfixedrecordfile:loadrange:invalidRange', 'Invalid range')
else
    irange = double(varargin{2});
end

if nargin<4 || isempty(varargin{3})
    %range = record indices
    data = load(frf, varargin{1}, irange(1):irange(2));
else
    %range = in field units
    flds = get(frf, 'fields');
    [dummy, fieldid] = ismember( varargin{3}, name(flds) ); %#ok
    
    if isempty(fieldid) || fieldid==0
        error('mwlfixedrecordfile:loadrange:invalidRange', 'Invalid range field')
    end
    
    fielddef = mex_fielddef( flds );
    
    idrange = findrecord( fullfile( get(frf, 'path'), get(frf, 'filename') ), irange, fielddef(fieldid,:), get(frf, 'headersize'), get(frf, 'recordsize') );
    
    if any(idrange==-1)
        error('mwlfixedrecordfile:loadrange:invalidRange', 'Invalid range - out of bounds')
    end

    data = load(frf, varargin{1}, idrange(1):idrange(2));
end
