function sh = deleteComments(sh)
%DELETECOMMENTS remove all comments from subheader
%
%  sh=DELETECOMMENTS(sh) delete all comments from subheader
%

%  Copyright 2005-2008 Fabian Kloosterman

i = find( strcmp(sh.parms(:,1), '') );

sh.parms(i,:) = [];

