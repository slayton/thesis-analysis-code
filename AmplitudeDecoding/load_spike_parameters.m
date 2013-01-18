function [out width waves] = load_spike_parameters(file, varargin)

args.idx = [];
args.time_range = [];
args.anti_idx = 0;
args = parseArgsLite(varargin,args);

out = ones(0,6);
width = [];

fields = {'waveform', 'timestamp'};
  
d = dir(file);
if d.bytes < 10000
    return;
end

mwlf = mwlopen(file);


if ~isempty(args.idx)
    f = load(mwlf, fields, args.idx);
else
    f = loadrange(mwlf,fields, args.time_range*10000, 'timestamp');
end

if logical(args.anti_idx)
    
    if isempty(args.time_range)
        error('no time range specified');
    end
    
    f2 = loadrange(mwlf, fields, args.time_range*10000, 'timestamp');
    
    [ignore,int_idx] = intersect(f2.timestamp, f.timestamp);
    idx = logical(f2.timestamp);
    idx(int_idx) = 0;
    f.timestamp = f2.timestamp(idx);
    f.waveform = f2.waveform(:,:,idx);
end




gains = get_gains(file);    

maxes = max(f.waveform, [], 2);
maxes = squeeze(maxes);
gains(gains==0) = inf;
gains = repmat(gains,size(maxes,2),1)';

u_volts = (10*double(maxes)./2048)./gains*1e6;

u_volts(u_volts>1000) = 0;
times = double(f.timestamp)/10000;  

out = [u_volts', times(:)];

width = get_spike_width(f.waveform);
waves = f.waveform;
    
end

function w = get_spike_width(wave)
	mw = squeeze(mean(wave));
    [mx mxind] = max(mw(5:12,:));
    mxind = mxind + 4;
    [mx mnind] = min(mw(13:end,:));
    mnind = mnind +12;

    w = (mnind - mxind);% * 3.2e-5;
end

function gains = get_gains(file)

    head = loadheader(file);

    chans = [0 1 2 3];

    if strcmp(head(1).Probe,'1')
        chans = chans+4;
    end

    strA = 'channel ';
    strB = ' ampgain';
    gains = nan(1,4);
    for j=1:length(chans);
        str(j,:) = [strA, num2str(chans(j)), strB];
        gains(j) = str2double(head(2).(str(j,:)));
    end
end        
