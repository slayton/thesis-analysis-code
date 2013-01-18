function f = mwlcreate(filename, filetype, varargin)
%MWLCREATE create a new mwl file
%
%  f=MWLCREATE(filename, filetype) creates a new mwl file object of the
%  specified type and with the specified file name. Valid file types are:
%  'diode', 'eeg', 'event', 'feature', 'fixedrecord', 'waveform'. The
%  header of the returned mwl file object is still open and can be
%  modified.
%
%  f=MWLCREATE(filename, filetype, param1, value1, ...) allows the caller
%  to set additional options. Valid options are:
%  FileFormat - 'binary' (default) or 'ascii'. Ascii format is not
%  supported by eeg or waveform files.
%  Mode - 'write' or 'overwrite'.
%  Header - Used to set the initial header of the file object. It should
%  be a valid header object. The option leaves the header open for
%  modifications.
%  Fields - Only valid for feature and fixedrecord files whih can handle
%  custom fields. It should be a valid mwlfield object Sets the data
%  fields in the file.
%  Data - Data to be written to disk. This option will close the header.
%  NSamples - Only valid for eeg and waveform files. Sets the number of
%  samples in an eeg buffer (default=1808) or in a waveform (default=32).
%  NChannels - Only valid for eeg and waveform files. Sets the number of
%  channels in an eeg buffer (default=8) or in a waveform (default=4).
%
%  Example
%    f=mwlcreate('test.dat', 'eeg', 'NSamples', 1000, 'NChannels', 4);
%
%    fields = mwlfield( {'x', 'y'}, {'short', 'short'}, 1 );
%    data = struct('x', 1:100', 'y', sin(1:100)');
%    f=mwlcreate('test.dat', 'feature', 'Fields', fields, 'Data', data);
%
%  See also MWLOPEN, MWLFIELD, MWLDIODEFILE, MWLEEGFILE, MWLEVENTFILE,
%  MWLFEATUREFILE, MWLFIXEDRECORDFILE, MWLWAVEFORMFILE, HEADER
%

%  Copyright 2005-2008 Fabian Kloosterman


args = struct('Header', [], 'Data', [], 'Fields', {[]}, 'FileFormat', 'binary', 'NSamples', [], 'NChannels', [], 'Mode', 'write');
args = parseArgs(varargin, args);

switch filetype
    case 'diode'
        f = mwldiodefile(filename, args.Mode, args.FileFormat);
    case 'eeg'
        f = mwleegfile(filename, args.Mode, args.NChannels, args.NSamples);
    case 'event'
        f = mwleventfile(filename, args.Mode, args.FileFormat);
    case 'feature'
        f = mwlfeaturefile(filename, args.Mode, args.FileFormat);
    case 'fixedrecord'
        f = mwlfixedrecordfile(filename, args.Mode, args.FileFormat);
    case 'rawpos'
        %f = mwlposfile(filename, 'w');
        error('mwlcreate:notImplemented', 'Not implemented')
    case 'waveform'
        f = mwlwaveformfile(filename, args.Mode, args.NChannels, args.NSamples);
    case 'cluster'
        %f = mwlfixedrecordfile(filename, 'w');
        error('mwlcreate:notImplemented', 'Not implemented')
    case 'clbound'
        f = mwlboundfile(filename, args.Mode, 'ascii');
    otherwise
        error('mwlcreate:unknownFileType', 'Unsupported file type')
end

%set header
if isa(args.Header, 'header')
    f = set(f, 'header', args.Header);
end

%set fields
if (strcmp(filetype, 'feature') || strcmp(filetype, 'fixedrecord') )
    if ~isempty(args.Fields)
        f = setFields(f, args.Fields);
    end
else
    f=setFields(f);
end

%write data
if ~isempty(args.Data)
    %close header
    f =closeHeader(f);    
    %append the data
    f = appendData(f, args.Data);
end
