function b = subsref(rfb,s)
%SUBSREF subscripted indexing
%
%  val=SUBSREF(f, subs) allows access to mwlrecordfilebase object
%  properties using the object.property syntax.
%


%  Copyright 2005-2008 Fabian Kloosterman

switch s(1).type
case '.'
    flds = {'fields'};
    id = find( strcmp(flds, s(1).subs) );
    if ~isempty(id)
        b = rfb.(flds{id});
        if numel(s)>1
          b = subsref(b, s(2:end) );
        end
    else
        b = subsref(rfb.mwlfilebase, s);
    end
end
