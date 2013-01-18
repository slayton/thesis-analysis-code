function sh = addComment(sh, comment)
%ADDCOMMENT add comment to subheader
%
%  sh=ADDCOMMENT(sh, comment) adds comment string to subheader.
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<2
  help(mfilename)
  return
end

if ~ischar(comment)
    error('subheader:addComment:invalidComment', 'Expecting comment string')
end

sh.parms(end+1,1:2) = {'' comment};

