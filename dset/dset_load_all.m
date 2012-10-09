function dset = dset_load_all(animal, day, epoch, varargin)
args = dset_get_standard_args();
args = args.load_all; 

args = parseArgs(varargin, args);

    
%Load the raw clusters, position, and eeg data from the .mat files
dset.clusters = dset_load_clusters(animal, day, epoch);
if mod(epoch,2)==0
    dset.position = dset_load_position(animal, day, epoch);
end

dset.description.animal = animal;
dset.description.day = day;
dset.description.epoch = epoch;
dset.description.args = args;

dset.epochTime = dset_load_epoch_times(animal, day, epoch);

% we only want to load 3 channels of EEG so lets figure out which channels to load 
% go through the list of cluster and count how often each tetrode
% appears, ignore tetrodes that aren't in CA1
tetCount = zeros(1,30);
tetLat = cell(1,30);
for j = 1:numel(dset.clusters)
    tet = dset.clusters(j).tetrode;
    % skip tetrodes not in the specified area
    if ~strcmp(dset.clusters(j).area, args.structure)
        continue;
    end
    tetCount(tet) = tetCount(tet)+1;
    tetLat{tet} = dset.clusters(j).hemisphere;
end

%sort the list of tetrodes by number of cells, sort the count and lat vectors using this list
[~, idx] = sort(tetCount, 2, 'descend');
tetCount = tetCount(idx);
tetLat = tetLat(idx);

% get a list of 3 channels, 2 from 1 side 1 from the other
chans = [0 0 0];
chanCount = 1;
% keep track of how many channels for each side have been grabbed
leftCount = 0; 
rightCount = 0;

for j = 1:numel(tetCount)
    % if channel is on the right and we have less than 2 right channels already
    if strcmp(tetLat{j}, 'right') && rightCount<2
        chans(chanCount) = idx(j);
        rightCount = rightCount+1;
        chanCount = chanCount + 1;
    % if channel is on the left and we have less than 2 right channels already
    elseif strcmp(tetLat{j}, 'left') 
         chans(chanCount) = idx(j);
        leftCount = leftCount+1;
        chanCount = chanCount+1;
    end
    % if all channels have been picked break
    if all(chans)
        break;
    end
end

chans(end+1) = dset_get_ref_channel(animal, day, epoch);
[dset.eeg dset.ref] = dset_load_eeg(animal, day, epoch, chans);

%old checks - but remove channels that aren't in the specified area
areaIdx = strcmp(args.structure, {dset.eeg.area});
dset.eeg = dset.eeg(areaIdx);

%figure out which channels are base, ipsi, and cont
%filter out all channels but 3, 2 ipsi chans and 1 cont chan
leftIdx = find(strcmp({dset.eeg.hemisphere}, 'left'));
rightIdx = find(strcmp({dset.eeg.hemisphere}, 'right'));

if isempty(leftIdx) || isempty(rightIdx)
    if numel(leftIdx>0)
        baseChan = leftIdx(1);
    else
        baseChan = rightIdx(1);
    end
    dset.eeg = dset.eeg(baseChan);
    dset.channels.base = baseChan;
    dset.channels.ipsiIdx = [];
    dset.channels.contIdx = [];    
else
    if numel(leftIdx)>1
        baseChan = leftIdx(1);
        ipsiChan = leftIdx(2);
        contChan = rightIdx(1);
    elseif numel(rightIdx) >1
        baseChan = rightIdx(1);
        ipsiChan = rightIdx(2);
        contChan = leftIdx(1);
    else
        error('Both leftIdx and rightIdx have fewer than 2 values!');
    end


    dset.eeg = dset.eeg([baseChan, ipsiChan, contChan]);

    dset.channels.base = 1;
    dset.channels.ipsi = 2;
    dset.channels.cont = 3;
    
    
    dset = dset_filter_eeg_ripple_band(dset);
end
% calcuate ripple events
%     for j = 1:3
%         [dset.ripples(j).window dset.ripples(j).maxTimes] = find_rip_burst(dset.eeg(j).data, dset.eeg(j).fs, dset.eeg(j).starttime);
%     end

lIdx = strcmp({dset.clusters.hemisphere}, 'left');
rIdx = strcmp({dset.clusters.hemisphere}, 'right');
tetId = cell2mat({dset.clusters.tetrode});

lTet = unique( tetId( lIdx));
rTet = unique( tetId( rIdx));

dset.mu = dset_load_mu(animal, day, epoch, 'timewin', dset.epochTime,'left', lTet, 'right', rTet);
if isfield(dset, 'position')
    dset.mu.bursts = dset_find_mua_bursts(dset.mu, 'pos_struct', dset.position);
else
    dset.mu.bursts = dset_find_mua_bursts(dset.mu, 'filter_on_velocity', 0);
end

[dset.amp.amps dset.amp.colnames] = dset_load_spike_wave_parameters(animal, day, epoch, 1:30);
dset.amp.info = dset_load_tetrode_info(animal, day, epoch);
%dset.amp.distmat = dset_load_distance_matrix(animal, day, epoch);


end
