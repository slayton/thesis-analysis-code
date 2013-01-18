function ef = mwleegfile(varargin)
%MWLEEGFILE mwleegfile constructor
%
%  f=MWLEEGFILE default constructor, creates a new empty mwleegfile
%  object.
%
%  f=MWLEEGFILE(f) copy constructor
%
%  f=MWLEEGFILE(filename) opens the specified mwl eeg file in read mode.
%
%  f=MWLEEGFILE(filename, mode) opens the mwl eeg file in the specified
%  mode ('read', 'write', 'append', 'overwrite').
%
%  f=MWLEEGFILE(filename, mode, nchan) will set the number of channels
%  for a new mwl eeg file opened in 'write' or 'overwrite' mode (default
%  = 8).
%
%  f=MWLEEGFILE(filename, mode, nchan, nsamples) will set the number of
%  samples per channel in a data buffer for a new file opened in 'write'
%  or 'overwrite' mode (default = 1808);
%
%  Note: only binary mwl eeg files are supported.
%
%  Example
%    %open eeg file
%    f = mwleegfile( 'data.eeg' );
%
%    %create new eeg file, with 16 channels and 1000 samples/channel
%    f = mwleegfile( 'data.eeg', 'write', 16, 1000 );
%
%  See also MWLFIXEDRECORDFILE, MWLRECORDFILEBASE, MWLFILEBASE
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin==0
  ef = struct('nsamples', 0, 'nchannels', 0);
  frf = mwlfixedrecordfile();
  ef = class(ef, 'mwleegfile', frf);
elseif isa(varargin{1}, 'mwleegfile')
  ef = varargin{1};
else
  frf = mwlfixedrecordfile(varargin{1:(min(end,2))});
  
  if strcmp(frf.format, 'ascii')
    error('mwleegfile:mwleegfile:invalidFile', 'Ascii eeg files are not supported.')
  end
  
  if ismember(frf.mode, {'read', 'append'})
    
    %eeg file?
    if ~strcmp( getFileType(frf), 'eeg')
      error('mwleegfile:mwleegfile:invalidFile', 'Invalid eeg file')
    end
    
    fields = frf.fields;
    
    if ~all(ismember(name(fields), {'timestamp', 'data'}))
      error('mwleegfile:mwleegfile:invalidFile', 'Invalid eeg file')
    end        
    
    ef.nsamples = length(fields(2));
    
    ef.nchannels = 0;
    
    hdr = get(frf, 'header');
    ef.nchannels = str2double( getFirstParam( hdr, 'nchannels') );
    
    %for h=1:len(hdr)
    %  sh = hdr(h);
    %  try
    %    ef.nchannels = str2double(getParam(sh, 'nchannels'));
    %  catch
    %    continue
    %  end
    %end
    
    if ef.nchannels == 0
      error('mwleegfile:mwleegfile:invalidFile', 'Cannot determine number of channels in file')
    end
    
    ef.nsamples = ef.nsamples ./ ef.nchannels;
    
    flds = get(frf,'fields');
    flds(2).n = [ef.nchannels ef.nsamples];
    frf = setFieldsInterp(frf,flds);    
    
  else
        
    if nargin<4 || isempty(varargin{4})
      ef.nsamples = 1808;
    else
      ef.nsamples = varargin{4};
    end
    
    if nargin<3 || isempty(varargin{3})
      ef.nchannels = 8;
    else
      ef.nchannels = varargin{3};
    end
    
    if ~isscalar(ef.nsamples) || ~isscalar(ef.nchannels) || ~isnumeric(ef.nchannels) || ~isnumeric(ef.nsamples)
      error('mwleegfile:mwleegfile:invalidArguments', 'Invalid nsamples and/or nchan arguments')
    end
    
  end
  
  ef = class(ef, 'mwleegfile', frf);
  
end
