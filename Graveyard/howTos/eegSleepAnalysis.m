path = '/home/slayton/data/spl04/09.01.23/';
path = '/home/slayton/data/miguel/1.0mgkg/';
eegfile = 'baseline-k-0123.eeg';
eegfile = 'slhigh16.eeg'
tetrodeDir = 'mu';
channel = 1;
eeg = loadEeg(strcat(path, eegfile), channel);
eeg.ripple.events = findRippleTimes(eeg.ripple.data, eeg.ripple.times, .020);
multiOn =0; %set to 0 for off, set to 1 for on.
multiOn  = multiOn>0;



% Run the commands below to look at the 
if multiOn
    multiUnit.times = singleToMulti(loadClusters(path, tetrodeDir));
    multiUnit.info = path;
    muRate = hist(multiUnit.times, multiUnit.times(1):1:multiUnit.times(end));
    plot(smoothn(muRate,10));
end;



% below is the code that will create a figure with 3 plots. 
% Ripple occurance on top (10 second bins)
% Multi Unit rates in the middle
% Theta/Delta power on the bottom

figure;
subplot(2+multiOn,1,1); hist(eeg.ripple.events, eeg.ripple.times(1):10:eeg.ripple.times(end));title('Ripples 10 second bins');
if multiOn
    subplot(2+multiOn,1,1+multiOn); plot(multiUnit.times(1):1:multiUnit.times(end), smoothn(muRate,10), 'r'); title('Multi Unit rate');
end;
subplot(2+multiOn,1,2+multiOn); plot(eeg.theta.times, eeg.theta.pow./eeg.delta.pow); title('Theta/Delta power');
linkaxes(get(gcf,'children'), 'x');



