function f = mwlopen(filename)
%MWLOPEN open a mwl file
%
%  f=MWLOPEN(filename) returns a mwl file object. This function tries to
%  determine the mwl file type from the header and returns an object of
%  the appropriate class.
%
%  Example
%    f = mwlopen( 'test.dat' );
%
%  See also MWLCREATE, MWLDIODEFILE, MWLEEGFILE, MWLEVENTFILE,
%  MWLFEATUREFILE, MWLFIXEDRECORDFILE, MWLPOSFILE, MWLWAVEFORMFILE,
%  MWLBOUNDFILE
%

%  Copyright 2005-2008 Fabian Kloosterman

f = mwlfilebase(filename);
filetype = getFileType(f);

switch filetype
    case 'diode'
        f = mwldiodefile(filename);
    case 'eeg'
        f = mwleegfile(filename);
    case 'event'
        f = mwleventfile(filename);
    case 'feature'
        f = mwlfeaturefile(filename);
    case 'fixedrecord'
        f = mwlfixedrecordfile(filename);
    case 'rawpos'
        f = mwlposfile(filename);
    case 'waveform'
        f = mwlwaveformfile(filename);
    case 'cluster'
        f = mwlfixedrecordfile(filename);
    case 'clbound'
        f = mwlboundfile(filename);
    otherwise
        error('mwlopen:invalidFile', 'Unsupported file type')
end
