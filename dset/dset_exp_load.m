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
% if strcmp(epoch(1:3), 'run')
%     dtypes = {'clusters', 'eeg', 'pos'};
% else
%     dtypes = {'eeg'};
% end
% e = exp_load(edir, 'epochs', {epoch}, 'data_types', dtypes);
% 
% e = process_loaded_exp(e, [1 2 3 4 7 8] );
% 
% dset.epochTime = e.(epoch).et;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %                        CONVERT  CLUSTERS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if isfield(e.(epoch), 'cl')
%     clE = e.(epoch).cl;
%     clD = repmat([], size(clE) );
% 
%     disp('step');
%     if ~isempty(fieldnames(clE))
%         for i = 1:numel(clE)
%             c.st = clE(i).st;
%             [~, c.day] = fileparts(edir);
%             c.epoch = epoch;
%             c.tetrode = num2str(c.tt(2:end));
%             c.area = clE(i).loc(2:end);
%             if clE(i).loc(1)=='l'
%                 c.hemisphere = 'left';
%             elseif clE(i).loc(2)=='r'
%                 c.hemisphere = 'right';   
%             end
%             clD(i) = c;
%         end
%     end
%     dset.cl = clD;
% end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        CONVERT  EEG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
[dset.eeg, dset.ref] = dset_exp_load_eeg(edir, epoch);
% ch = exp_get_preferred_eeg_channels(edir);
% eeg = e.(epoch).eeg;
% fs = 1.000 / mean(diff(eeg.ts));
% 
% 
% for i = 1:3
%     
%     dset.eeg(i).data = eeg.data(:,ch(i));
%     dset.eeg(i).fs = fs;
%     dset.eeg(i).starttime = eeg.ts(1);
%     dset.eeg(i).area = 'CA1';
%     if eeg.loc{ch(i)}(1) == 'l'
%         dset.eeg(i).hemisphere = 'left';
%     else
%         dset.eeg(i).hemisphere = 'right';
%     end
%     dset.eeg(i).tet = 'Unknown';
%     
% end
% dset.ref.fs = dset.eeg(1).fs;
% dset.ref.starttime = dset.eeg(1).starttime;
% dset.ref.data = zeros( size( dset.eeg(1).data) );

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
dset.mu = dset_exp_load_mu(edir, epoch);



    
    
    
    
    