function [result, i] = getComments(sh)
%GETCOMMENTS return all comments in subheader
%
%  comments=GETCOMMENTS(sh) returns all comments in subheader.
%
%  [comments, loc]=GETCOMMENTS(sh) also returns the locations (i.e. line
%  numbers) of the comments.
%

%  Copyright 2005-2008 Fabian Kloosterman

i = find( strcmp(sh.parms(:,1), '') );

result = sh.parms(i,2);

