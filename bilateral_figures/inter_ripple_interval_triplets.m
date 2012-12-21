
clear
iExp = 1;
if ~exist('allRipples','var')
    allRipples = dset_load_ripples;
end
% epType = 'sleep';

ripples = allRipples.sleep(end-12:end-7);

tripIriSlp = [];
allIriSlp = [];
for iExp = 1:numel(ripples)
    rips = ripples(iExp);
   
    
    ripTs = rips.peakIdx * 1/rips.Fs;
    
    tripIdx = filter_event_sets(ripTs, 3, [.5 .25 .25]);
    tripTs = ripTs(tripIdx);
    
    iri = [50; diff(ripTs)];
    
    setIdx = false(size(ripTs));
    
    for iRip = 1:numel(tripTs)
        setIdx = setIdx | ( ripTs > tripTs(iRip) & ripTs < tripTs(iRip) + 1 );
    end
    
    
    tripIriSlp = [tripIriSlp; iri(setIdx)];
    allIriSlp = [allIriSlp; iri];
end


ripples = allRipples.run(end-12:end-7);

tripIriRun = [];
allIriRun = [];
for iExp = 1:numel(ripples)
    rips = ripples(iExp);
   
    
    ripTs = rips.peakIdx * 1/rips.Fs;
    
    tripIdx = filter_event_sets(ripTs, 3, [.5 .25 .25]);
    tripTs = ripTs(tripIdx);
    
    iri = [50; diff(ripTs)];
    
    setIdx = false(size(ripTs));
    
    for iRip = 1:numel(tripTs)
        setIdx = setIdx | ( ripTs > tripTs(iRip) & ripTs < tripTs(iRip) + 1 );
    end
    
    
    tripIriRun = [tripIriRun; iri(setIdx)];
    allIriRun = [allIriRun; iri];
end
%%

b = 0:.005:1;


hTripSlp = histc(tripIriRun, b);
hAllSlp = histc(allIriRun, b);

hTripSlp = smoothn(hTripSlp, 2);
hAllSlp = smoothn(hAllSlp, 2);

hTripSlp = hTripSlp - min(hTripSlp);
hTripSlp = hTripSlp / max(hTripSlp);

hAllSlp = hAllSlp - min(hAllSlp);
hAllSlp = hAllSlp / max(hAllSlp);
% 
% hTripRun = histc(tripIriRun, b);
% hAllRun = histc(allIriRun, b);
% 
% hTripRun = smoothn(hTripRun, 2);
% hAllRun = smoothn(hAllRun, 2);
% 
% hTripRun = hTripRun - min(hTripRun);
% hTripRun = hTripRun / max(hTripRun);
% 
% hAllRun = hAllRun - min(hAllRun);
% hAllRun = hAllRun / max(hAllRun);

figure;

line(b, hTripSlp, 'color', 'b');
line(b, hAllSlp, 'color', 'r')