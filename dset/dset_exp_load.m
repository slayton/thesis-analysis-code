function dset = dset_exp_load(edir, epoch)
% load a exp as a dset
% DSET
%   - clusters
%       -st
%       -tetrode
%       -clustId
%       -area
%       -hemisphere
%       -pf
%       -pf_edges
%
%   - position
%       -ts
%       -rawx
%       -rawy
%       - smooth_vel
%       - linear_sections
%       - many more
%   - description
%       - animal 'Name'
%       - day: num
%       - epoch: num
%       - args
%   - epochTime: [start stop]
%
%   - eeg(struct array)
%       - data
%       - starttime
%       - fs
%       - hemisphere
%       - area
%       - tet
%   - ref
%       -data
%       -starttime
%       -fs
%
%   - channels
%       -base 1
%       -ipsi 2
%       -cont 3
%   - mu
%       - rate
%       - rateL
%       - rateR
%       - timestamps
%       - fs
%       - bursts Nx2
%   - amp
if strcmp(epoch(1:3), 'run')
    dtypes = {'clusters', 'eeg', 'pos'};
else
    dtypes = {'eeg'};
end
e = exp_load(edir, 'epochs', {epoch}, 'data_types', dtypes);

e = process_loaded_exp(e, [1 2 3 4 7 8] );

dset.epochTime = e.(epoch).et;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        CONVERT  CLUSTERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isfield(e.(epoch), 'cl')
    clE = e.(epoch).cl;
    clD = struct(size(clE));

    for i = 1:numel(clE)
        c.st = clE(i).st;
        [~, c.day] = fileparts(edir);
        c.epoch = epoch;
        c.tetrode = num2str(c.tt(2:end));
        c.area = clE(i).loc(2:end);
        if clE(i).loc(1)=='l'
            c.hemisphere = 'left';
        elseif clE(i).loc(2)=='r'
            c.hemisphere = 'right';   
        end
        clD(i) = c;
    end
    dset.cl = clD;
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        CONVERT  EEG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

ch = exp_get_preferred_eeg_channels(edir);
eeg = e.(epoch).eeg;
fs = 1.000 / mean(diff(eeg.ts));

for i = 1:3
    
    dset.eeg(i).data = eeg.data(:,ch(i));
    dset.eeg(i).fs = fs;
    dset.eeg(i).starttime = eeg.ts(1);
    dset.eeg(i).area = 'CA1';
    if eeg.loc{ch(i)}(1) == 'l'
        dset.eeg(i).hemisphere = 'left';
    else
        dset.eeg(i).hemisphere = 'right';
    end
    dset.eeg(i).tet = 'Unknown';
    
end
dset.ref.fs = dset.eeg(1).fs;
dset.ref.starttime = dset.eeg(1).starttime;
dset.ref.data = zeros( size( dset.eeg(1).data) );

dset.channels.base = 1;
dset.channels.ipsi = 2;
dset.channels.cont = 3;

dset = orderfields(dset);
    
[rem, day] = fileparts(edir);
[~, anim] = fileparts(rem);
dset.description.animal = anim;
dset.description.day = day;
dset.description.epoch = epoch;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        CONVERT  MULTI-UNIT ACTIVITY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
[tt loc] = load_exp_tt_anatomy(edir);

anat = unique(loc);
muDt = 1/200;
tbins = dset_calc_timestamps(dset.eeg(1).starttime, numel(dset.eeg(1).data), dset.eeg(1).fs);
tbins = tbins(1):muDt:(tbins(end)-muDt);

disp('Loading Multiunit!');
for a = 1:numel(anat)
    
    ind = ismember(loc,anat(a));
    %disp(['loading multi-unit rate from: ', anat{a}]);
    wave = load_exp_mu(edir, epoch, 'ignore_tetrode', tt(~ind));

    wave = histc(wave,tbins);
    dset.mu.ts = tbins;

    if ~isempty(wave)
        %wave( wave>(mean(wave)+10*std(wave)))=mean(wave);
        dset.mu.(anat{a}) = wave;
    else
        dset.mu.(anat{a}) = nan;
    end
    dset.mu.timestamps = tbins;
    dset.mu.Fs = muDt^-1;
    
end

if isfield(dset.mu, 'lCA1')
    dset.mu.rateL = dset.mu.lCA1;
    dset.mu = rmfield(dset.mu, 'lCA1');
end

if isfield(dset.mu, 'rCA1')
    dset.mu.rateR = dset.mu.rCA1;
    dset.mu = rmfield(dset.mu, 'rCA1');
end

if isfield(dset.mu, 'rCA3')
    dset.mu = rmfield(dset.mu, 'rCA3');
end
if isfield(dset.mu, 'lCA3')
    dset.mu = rmfield(dset.mu, 'lCA3');
end

args = dset_get_standard_args;
args = args.multiunit;

dset.mu.rateL = smoothn(dset.mu.rateL, args.smooth_dt, args.dt);
dset.mu.rateR = smoothn(dset.mu.rateR, args.smooth_dt, args.dt);
dset.mu.rate = dset.mu.rateL + dset.mu.rateR;
dset.mu.bursts = dset_find_mua_bursts(dset.mu, 'filter_on_velocity', 0);



    
    
    
    
    