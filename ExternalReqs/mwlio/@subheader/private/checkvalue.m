function val=checkvalue(val)
%CHECKVALUE

if ischar(val)
  %fine
elseif isnumeric(val)
  val = num2str(val, 8);
elseif iscell(val)
  val = char(val);
else
  error('subheader:checkvalue:invalidValue', ...
        'Conversion of value to string is not possible')
end