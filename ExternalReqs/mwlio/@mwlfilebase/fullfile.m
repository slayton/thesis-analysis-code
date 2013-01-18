function filename = fullfile(f)
%FULLFILE return full path to file
%
%  filename=FULLFILE(f) return the full path to the mwl file represented
%  by the mwlfilebase object.
%
%  Example
%    f = mwlfilebase('test.dat')
%    name = fullfile( f );
%
%  See also MWLFILEBASE
%

%  Copyright 2005-2008 Fabian Kloosterman

filename = fullfile(f.path, f.filename);
