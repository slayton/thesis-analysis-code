function [events, env, params] = detect_ripples(ts, x, varargin)

timestampCheck(ts);
Fs = 1 / (ts(2) - ts(1));

args.high_thold = 7;
args.low_thold = 2;
parseArgs(varargin, args);



%b = make_ripple_filter(Fs, args.band);
b = getfilter(Fs, 'ripple', 'win');
x = filtfilt(b, 1, x);

x = x - mean(x);

env = abs( hilbert( x ));

thH = mean(env) + std(env)*args.high_thold;
thL = mean(env) + std(env)*args.low_thold;


high_seg = logical2seg(ts, env>=thH);
low_seg = logical2seg(ts, env>=thL);

[b n] = inseg(low_seg, high_seg);

events = low_seg(logical(n),:);


end
