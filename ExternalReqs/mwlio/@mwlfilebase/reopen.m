function f = reopen(fb) %#ok
%REOPEN reopen file
%
%  f=REOPEN(f) rereads the header of the mwl file and returns a new
%  mwlfilebase object. This function is used internally to reopen a file
%  in append mode after the header has been closed.
%
%  Example
%    f = mwlfilebase('test.dat', 'write');
%    f = reopen(f);
%
%  See also CLOSEHEADER, MWLFILEBASE
%

%  Copyright 2005-2008 Fabian Kloosterman

if ismember(fb.mode, {'write', 'overwrite'})
    error('mwlfilebase:reopen:invalidMode', ['File is in ' fb.mode ' mode. Cannot reopen.'])
end

if nargout<1
    warning('mwlfilebase:reopen:noOuput', 'Please supply output variable. File not reopened.')
    return  
end

cl = class(fb);

eval(['f = ' cl '( ''' fullfile(fb.path, fb.filename) ''', ''' fb.mode  ''' );']);
