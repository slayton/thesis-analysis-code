function [events, smoothEnv, params] = detect_spindles(ts, x, varargin)

timestampCheck(ts);
Fs = 1 / (ts(2) - ts(1));

args.band = [10 15];
args.tholdStd = 1.5;
args.eventLen = [.5 3];
parseArgs(varargin, args);


b = make_spindle_filter(Fs, args.band);
x = filtfilt(b, 1, x);

env = abs(hilbert(x));

k = make_smoothing_kernel(Fs);
smoothEnv = conv(env, k, 'same');

thold = mean(smoothEnv) + args.tholdStd * std(smoothEnv);

detector = smoothEnv > thold;
detector = [diff(detector); nan];

tsStart = ts(  detector==1 );
tsEnd = ts( detector==-1);

events = [tsStart(:), tsEnd(:)];

duration = diff(events,[],2);

validIdx = duration> args.eventLen(1)  & duration< args.eventLen(2);

events = events(validIdx,:);

params.bandpass_filter = b;
params.smoothing_kernel = k;


end

function b = make_spindle_filter(Fs, freqBand)
    
    n = ceil( 6 * (Fs/freqBand(1)));

    if mod(n,2)
        n = n+1;
    end

    if Fs < 2*freqBand(2)
        error('Cutoff frequency is above the Nyquist limit');
    end
    
    b = fir1(n, 2 * freqBand ./ Fs, blackman(n+1) );
end

function k = make_smoothing_kernel(Fs)

n = round(Fs);
k = normpdf(-n:n, 0, Fs/6);

end
