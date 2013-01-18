function f=subsasgn(f,subs,val)
%SUBSASGN subscripted assignment
%
%  f=SUBSASGN(f,subs,val) support for subscripted assignment. Valid
%  syntaxes are:
%   1. f(i)=f2 - replace fields
%   2. f(i).name, f(i).type, f(i).n - set property of fields
%

%  Copyright 2006-2008 Fabian Kloosterman

if numel(subs)<2
  if strcmp(subs(1).type,'()') && isa(val, 'mwlfield')
    f(subs(1).subs{:}) = val;
  else
    error('mwlfield:subsasgn:invalidAssignment', 'invalidAssignment');  
  end
elseif strcmp(subs(1).type, '()') && strcmp(subs(2).type, '.')
  idx = subs(1).subs;
  switch subs(2).subs
   case 'name'
    if ~ischar(val)
      error('mwlfield:subsasgn:invalidAssignment', 'Name has to be a string')
    end
   case 'type'
    if ischar(val)
      val = mwltypemapping(val, 'str2code');
    elseif isempty(val) || ~isnumeric(val) || val<1 || val>10
      error('mwlfield:subsasgn:invalidAssignment', 'Invalid type code')
    end
   case 'n'
    if isempty(val) || ~isnumeric(val) || ~isvector(val)
      error('mwlfield:subsasgn:invalidAssignment', 'Invalid size')
    else
      val = val(:)';
    end
   otherwise
    error('mwlfield:subsasgn:invalidAssignment', 'invalid assignment');    
  end
  [f(idx{:}).(subs(2).subs)] = deal( val );
else
  error('mwlfield:subsasgn:invalidAssignment', 'invalid assignment');
end
  
