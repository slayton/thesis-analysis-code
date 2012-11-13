function [mu, p, leftCounts, rightcounts] = dset_load_mu(animal, day, epoch, varargin)
% DSET_LOAD_MU - loads the gross unsorted firing rate for a set of electrodes

args = dset_get_standard_args;
args = args.multiunit;

args = parseArgs(varargin, args);

% default behavior is to load the timewindow information from the position
% record

if isempty(args.timewin) && args.load_time_from_position && isempty(args.pos_struct)
    p = dset_load_position(animal, day, epoch);
    args.timewin = [p.ts(1) p.ts(end)];    
elseif isempty(args.timewin) && args.load_time_from_position
    p = args.pos_struct;
    args.timewin = [p.ts(1) p.ts(end)];       
end

% create the vector of firing rates
tbins = (args.timewin(1):args.dt:args.timewin(2))';
spikeCounts = zeros(size(tbins));

if ~isempty(args.left)
    leftCounts = zeros(size(tbins));
end

if ~isempty(args.right)
    rightCounts = zeros(size(tbins));
end

for i = 1:numel(args.electrodes)
    % load the spikes for each specified electrode
    filepath = dset_get_spike_param_file_path(animal, day, epoch, args.electrodes(i));
    if ~exist(filepath, 'file')
        continue;
    end
    
    data = load(filepath);
    data = data.filedata;
    
    chanIdx = find(strcmp(data.paramnames, args.param_str));
    timeIdx = find(strcmp(data.paramnames, 'Time'));
    
    % threshold the spikes
    idx = data.params(:,chanIdx)>args.threshold;
    ts = data.params(idx, timeIdx) / args.spike_samp_rate;

    tmpCounts = reshape( histc( ts, tbins), [], 1);
    spikeCounts = spikeCounts + tmpCounts;   
    
    if any(i == args.left)
        leftCounts = leftCounts + tmpCounts;
    end
    if any(i == args.right)
        rightCounts = rightCounts + tmpCounts;
    end
end

mu.rate = spikeCounts;
mu.rateL = leftCounts;
mu.rateR = rightCounts;
if args.smooth == 1
    mu.rate = smoothn(mu.rate, args.smooth_dt, args.dt);
end
%convert from counts to rate
%mu.rate = spikeCounts ./ args.dt;

mu.timestamps = tbins;
mu.fs = 1/args.dt;


