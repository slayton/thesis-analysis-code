function h = subsasgn(h,s,b)
%SUBSASGN subscripted assignment
%
%  h=SUBSASGN(h, subs, val) subscripted assignment to add (or replace)
%  subheaders to a header object and to set parameters in subheaders. The
%  following syntaxes are supported:
%   1. h.parameter=value - set parameter in all subheaders
%   2. h.('parameter')=value - idem as 1
%   3. h(i)=header/subheader - replace subheaders
%   4. h(i).parameter=value - set parameter for subset of subheaders
%  Note that if value is empty, the parameter or subheader is deleted.
%
%  Example
%    h = header('a',1,'b',2);
%    h(2:3) = sh; %create 2nd and 3rd subheader
%    h(2).a = 7; %set parameter in 2nd subheader
%

%  Copyright 2005-2008 Fabian Kloosterman

nh = length(h.subheaders);

switch s(1).type
 case '()'
  %if ischar(s(1).subs{1}) && ~strcmp(s(1).subs{1},':')
  %  if nh>0
  %    h.subheaders(1) = setParam(h.subheaders(1), s(1).subs{1}, b);
  %  else
  %    h.subheaders = subheader(s(1).subs{1},b);
  %  end
  %else
    ind = s(1).subs{1};
    if isequal(ind,':')
      ind = 1:nh;
    end
    %add new subheaders if necessary
    if (max(ind)>nh)
        if nh==0
            h.subheaders = subheader();
        end
        h.subheaders(max(ind)) = subheader();
    end
    %if any( ind<1 | ind>nh )
    %  error('header:subsasgn:invalidIndexing', 'Invalid index')
    %end
    if length(s)>1 && strcmp(s(2).type,'.')
      for k=1:numel(ind)
        h.subheaders(ind(k)) = setParam(h.subheaders(ind(k)),s(2).subs,b);
      end
    else
      if isempty(b)
        h.subheaders(ind) = [];
      else
        switch class(b)
         case 'header'
          if numel(ind)~=numel(b.subheaders)
            error('header:subsasgn:invalidAssignment', 'Invalid assignment');
          else
            h.subheaders(ind) = b.subheaders;
          end
         case 'subheader'
          if numel(b)~=1 && numel(ind)~=numel(b)
            error('header:subsasgn:invalidAssignment', 'Invalid assignment');
          else
            h.subheaders(ind) = b;
          end      
         otherwise
          error('header:subsasgn:invalidAssignment','Invalid assignment')
        end
      end
    end
  %end
 case '.'
  nh = length(h.subheaders);
  for k=1:nh
    h.subheaders(k) = setParam( h.subheaders(k), s(1).subs,b );
  end  
 otherwise
  error('header:subsasgn:invalidIndexing', 'Invalid assignment')  
end

