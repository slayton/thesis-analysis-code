function b = subsref(frf,s)
%SUBSREF subscripted indexing
%
%  val=SUBSREF(f, subs) adds support for getting properties and loading
%  data using subscripted references. Valid syntaxes are:
%   1. f(i) - load subset of records (':' and 'end' are allowed)
%   2. f.field - load all records of selected field
%   3. f(i).field - load subset of records of select field
%   4. f.property - get file property
%


%  Copyright 2005-2008 Fabian Kloosterman

n = numel(s);

if strcmp( s(1).type, '()' )
  
  %process the indices for a partial load
  if ischar(s(1).subs{1}) && isequal(s(1).subs{1},':')
    ind = 0:(get(frf,'nrecords')-1);
  else
    ind = s(1).subs{1};
  end
  
  if n==1 %do partial load of all fields
    b = load(frf, 'all', ind );
    return
  end

  %remove first indexing
  s(1) = [];
  
else
  
  ind = 0:(get(frf,'nrecords')-1);
  
end
    
if strcmp( s(1).type, '.' )
  fields = get(frf, 'fields_interpretation');
  if isempty(fields)
    fields = get(frf,'fields');
  end  

  if ~isempty(fields) && any( strcmp(s(1).subs, name(fields) ) ) %load data
    b = load( frf, s(1).subs, ind);
    b = b.(s(1).subs);
  elseif ~isempty(fields) && any( strcmp( strrep( s(1).subs, '_', ' '), name(fields) ) )    
    b = load( frf, strrep( s(1).subs, '_', ' '), ind);
    b = b.(s(1).subs);
  elseif strcmp(s(1).subs, 'nrecords')
    b = get(frf, 'nrecords');
  elseif strcmp(s(1).subs, 'recordsize')
    b = frf.recordsize;
  else
    b = subsref(frf.mwlrecordfilebase, s);    
  end
  
  return
  
end


%still here? that's an error!
error('mwlfixedrecordfile:subsref:invalidIndexing', 'invalid indexing')
