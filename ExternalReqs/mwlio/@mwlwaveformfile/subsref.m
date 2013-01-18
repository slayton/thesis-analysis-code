function b = subsref(ef,s)
%SUBSREF subscripted indexing
%
%  val=SUBSREF(f, subs) allows access to mwlwaveformfile object
%  properties using the object.property syntax.
%


%  Copyright 2005-2008 Fabian Kloosterman

switch s(1).type
case '.'
  flds = {'nsamples' 'nchannels'};
  id = find( strcmp(flds, s(1).subs) );
  if ~isempty(id)
      b = ef.(flds{id});
      if numel(s)>1
          b = subsref(b, s(2:end) );
      end
  else
      b = subsref(ef.mwlfixedrecordfile, s);
  end
otherwise
  
  b = subsref(ef.mwlfixedrecordfile, s);

end
