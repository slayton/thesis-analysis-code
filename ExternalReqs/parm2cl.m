function [cl trode] = parm2cl(varargin)
% PARM2CL create a cl struct (and trode struct) from a parm file, calcs peak/radius
% $Id: parm2cl.m 521 2009-04-24 01:23:23Z tjd $  
  
  a = struct(...
      'epos', [],...
      'parmfile', [],... 
      'tetname', [],...
      'trodeno', [],...
      'clno', [],...
      'ad', [],...
      'usefields', {{'t_px' 't_py' 't_pa' 't_pb' 't_maxwd'}},... % fields to import
      'adunits_fields', {{'t_px' 't_py' 't_pa' 't_pb'}},... % fields needing offset, conversion to uv
      'thresh_fields', {{'t_px' 't_py' 't_pa' 't_pb'}},... % fields to use for thresh
      'uvthresh', [],...
      'offset', 0,...
      'gain', [],...
      'rate', [],...
      'adbugfix', true,...
      'timewin', [-Inf Inf]);
  
  a = parseArgsLite(varargin,a);
  
  % deal with rate/gain
  if ~isempty(a.ad)
    %try to get rate/gains from adstruct
    rate = a.ad.rate;
    if isfield(a.ad, 'chan0ampgain'),
      gain = [a.ad.chan0ampgain a.ad.chan1ampgain ...
              a.ad.chan2ampgain a.ad.chan3ampgain];
    elseif isfield(a.ad, 'chan4ampgain'),
      gain = [a.ad.chan4ampgain a.ad.chan5ampgain ...
              a.ad.chan6ampgain a.ad.chan7ampgain];
    end
  else
    gain = a.gain;     
    rate = a.rate;
  end
  
  switch numel(gain)
   case 0
    error(['gain must be specified, either with ''gain'' argument, or an ' ...
           'ad struct passed in as ''ad'' argument']);

   case 1
    gain = repmat(gain, 1, numel(a.adunits_fields));
    
   case numel(a.adunits_fields)
    % ok
    
   otherwise
    error(['If multiple gain values are specified, there must be 1 for ' ...
           'each ''adunits_fields''']);
    
  end
  
    
  % load parm file!
  f = load(mwlopen(a.parmfile));
  
  nrecs = size(f.(a.usefields{1}),2);
  
  if isempty(a.adunits_fields),
    a.adunits_fields = a.usefields;
  end

  if isempty(a.thresh_fields),
    a.thresh_fields = a.adunits_fields;
  end
    
  if ~all(ismember(a.adunits_fields, a.usefields)) ||...
    ~all(ismember(a.thresh_fields, a.usefields)),
    error(['''adunits_fields'' and ''thresh_fields'' must be subsets of ' ...
           '''usefields'' argument']);
  end
  
  % AD units to microvolts conversion factor
  ad_to_uv = 1e-6 * gain * 2048/10;
    
  
  %% Select only requested timewin first, before doing any calcns
  tstart = a.timewin(1);
  tend = a.timewin(2);

% $$$   tstart = find(f.time > tstart, 1, 'first')-1;
% $$$   if tstart < 1, tstart = 1; end
% $$$   
% $$$   tend = find(f.time < tend, 1, 'last')+1;
% $$$   if tend > length(f.time), tend = length(f.time); end

  recstart = find(f.time > tstart,1,'first');
  if isempty(recstart), recstart = 1; end

  recend = find(f.time < tend,1,'last');
  if isempty(recend), recend = nrecs; end
  
  for fname = {'time' 'id' a.usefields{:}}
    fname = fname{:};
    newf.(fname) = f.(fname)(:,recstart:recend)';
  end
  
  nrecs_new = recend - recstart + 1;
  
% $$$   %% add offset and then threshold
% $$$   if ~isempty(a.uvthresh),
% $$$     adthresh = a.uvthresh ./ ad_to_uv;
% $$$   else 
% $$$     adthresh = [];
% $$$   end
  
  % fix bug where occasionally we get very high-valued points from AD
  goodi_adbug = true(nrecs_new,1);
  if a.adbugfix,
    for fname = a.thresh_fields;
      fname = fname{:};
      if isfield(newf, fname)
        goodi_adbug = goodi_adbug & newf.(fname) <=2048;
      end
    end
  end
  
  % correct AD offset so that 0 AD units = 0uv
  for k = 1:length(a.adunits_fields);
    fname = a.adunits_fields{k};
    % add offset
    if isfield(newf, fname)
      if ~isempty(a.offset),
        % avoid changing class of data b/c of offset
        offset = cast(a.offset, class(newf.(fname)));
        newf.(fname) = newf.(fname) + offset;
      end
      
      % convert ad units to uv and change name to *_uv
      newf.([fname '_uv']) = double(newf.(fname)) ./ ad_to_uv(k);
      newf = rmfield(newf,fname);
      
      % update all args to reflect new *_uv field names      
      a.usefields = strrep(a.usefields, fname, [fname '_uv']);
      a.adunits_fields = strrep(a.adunits_fields, fname, [fname '_uv']);
      a.thresh_fields = strrep(a.thresh_fields, fname, [fname '_uv']);
    end
  end
  
  % select only spikes with one channel above threshold, calculate peak
  if isempty(a.uvthresh)
    goodi_th = true;
  else
    goodi_th = false(nrecs_new,1);
  end
  
  peak_uv = -Inf(nrecs_new,1);
  radius_uv = zeros(nrecs_new,1);
  
  for fname = a.thresh_fields
    fname = fname{:};
    
    % calculate peak across channels
    peak_uv = max(peak_uv, double(newf.(fname)));

    % n-d pythagorean distance is sqrt of sum of the squares
    % (this loop sums the squares, we take the root below)
    radius_uv = radius_uv + (double(newf.(fname)) .^2);
    
    if ~isempty(a.uvthresh)  
      % build index of spikes with one parm above threshold
      goodi_th = goodi_th | newf.(fname) > a.uvthresh;
    end
  end

  % (root of sum of squares calc'd in loop above)
  radius_uv = sqrt(radius_uv);
  
  % combine selection criteria
  goodi = goodi_th & goodi_adbug;
  
  if ~isempty(goodi)
    % build cluster data
    cldat(:,1) = double(newf.time(goodi));
    cldat(:,2) = double(newf.id(goodi));
    for k = length(a.usefields):-1:1 % pre-allocates full array on first call
      cldat(:,k+2) = double(newf.(a.usefields{k})(goodi,:))';
    end
  else
    cldat = [];
  end
    
  name = [a.tetname '_parm_thresh_' num2str(a.uvthresh) 'uv'];
  
  cl.electrode = a.trodeno;
  cl.name = name;
  cl.score = [];
  cl.flds = [{'time' 'id'} a.usefields {'peak_uv' 'radius_uv'}];
  cl.dat = [cldat peak_uv(goodi) radius_uv(goodi)];
  
  % add in e.pos indexes, if epos provided
  if ~isempty(a.epos),
    cl = addclpos(cl, a.epos);
  end

  
  trode = struct('name', name,...
                 'cls', a.clno,...
                 'type', 'tetrode', ...
                 'ad', a.ad, ...
                 'rate', rate, ...
                 'gain', gain);
  

