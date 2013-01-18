function t = headerType(sh)
%HEADERTYPE return the mwl-type of the subheader
%
%  hdrtype=HEADERTYPE(sh) returns the type of subheader. The type is
%  determined as follows: If the subheader contains the parameter 'File
%  Format', then the type is the value of this parameter. Otherwise the
%  type is determined by checking the values of the parameters 'Program'
%  and 'Extraction type' (in case of adextract). If there is no 'Program'
%  parameter but there is a 'adversion' parameters it is assumed that
%  subheader is from a raw ad data file. Possible header types returned
%  by this method: 'event', 'eeg', 'rawpos', 'waveform', 'diode',
%  'feature', 'cluster', 'clbound', 'ad', 'unknown'
%

%  Copyright 2005-2008 Fabian Kloosterman


%File Format field?
parm_id = find( strcmp(sh.parms(:,1), 'File Format') );
if parm_id
  t = sh.parms{parm_id, 2};
  return
end

%Program field?
parm_id = find( strcmp(sh.parms(:,1), 'Program') );
if parm_id
  %there is a program field
  program = sh.parms{parm_id, 2};
  if findstr(program, 'adextract')
    %adextract created this file
    exparm = find( strcmp(sh.parms(:,1), 'Extraction type') );
    if exparm
      et = sh.parms{exparm, 2};
      if strcmp(et, 'event strings')
        t = 'event';
      elseif strcmp(et, 'continuous data')
        t = 'eeg';
      elseif strcmp(et, 'extended dual diode position')
        t = 'rawpos';
      elseif strcmp(et, 'tetrode waveforms')
        t = 'waveform';
      else
        t = 'unknown';
      end
    else
      t = 'unknown';
    end
  elseif findstr(program, 'posextract')
    t = 'diode';
  elseif findstr(program, 'spikeparms')
    t = 'feature';
  elseif findstr(program, 'crextract')
    t = 'feature';
  elseif findstr(lower(program), 'xclust')
    if any( strcmp(sh.parms(:,1), 'Cluster') )
      t = 'cluster';
    else
      t = 'clbound';
    end
  else
    t = 'unknown';
  end
else
  adid = find( strcmp(sh.parms(:,1), 'adversion') );
  if adid
    t = ['ad ' sh.parms{adid,2}];
  else
    t = 'unknown';
  end
end

