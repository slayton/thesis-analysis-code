
clear
%%
iExp = 1;
if ~exist('allRipples','var')
    allRipples = dset_load_ripples;
end
% epType = 'sleep';


%%
tripIri.sleep = {[],[]};
tripIri.run = {[],[]};
allIri.sleep = {[],[]};
allIri.run = {[],[]};

for ep = {'sleep', 'run'}
    
    ep = char(ep);
    
    ripples = allRipples.(ep);

   for iExp = 1:numel(allRipples.(ep))
%   for iExp = 8:13%:numel(allRipples.(ep))
%   for iExp = 14:numel(allRipples.(ep))

        rips = allRipples.(ep)(iExp);

        ripTs = rips.peakIdx /rips.Fs;
        ripLen = diff(rips.eventIdx, [], 2);
        
        randOffset = randomInts(ripLen + 1) - 1;
        randTs = (rips.eventIdx(:,1) + randOffset ) / rips.Fs;    
        
%         randTs = rips.eventIdx(:,1) / rips.Fs;  % start of event
         randTs = rips.eventIdx(:,2) / rips.Fs;  % End of event

        realTripIdx = filter_event_sets(ripTs, 3, [.5 .25 .25]);
        randTripIdx = filter_event_sets(randTs, 3, [.5 .25 .25]);
        
        realTripTs = ripTs(realTripIdx);
        randTripTs = randTs(randTripIdx);

        iriReal = [50; diff(ripTs)];
        iriRand = [50; diff(randTs)];

        realSetIdx = false(size(ripTs));
        randSetIdx = false(size(randTs));

        for iRip = 1:numel(realTripTs)
            realSetIdx = realSetIdx | ( ripTs > realTripTs(iRip) & ripTs < realTripTs(iRip) + 1 );
        end
        
        for iRip = 1:numel(randTripTs)
            randSetIdx = randSetIdx | ( randTs > randTripTs(iRip) & randTs < randTripTs(iRip) + 1 );
        end

        tripIri.(ep){1} = [tripIri.(ep){1}; iriReal(realSetIdx)];
        tripIri.(ep){2} = [tripIri.(ep){2}; iriRand(randSetIdx)];

        allIri.(ep){1} = [allIri.(ep){1}; iriReal];
        allIri.(ep){2} = [allIri.(ep){2}; iriRand];

    end
end

%%

b = 0 : 0.0025 : 0.25;


for ep = {'sleep', 'run'}
    
    ep = char(ep);
   
    for i = 1:2
        hTrip.(ep){i} = histc(tripIri.(ep){i}, b);
        hAll.(ep){i} = histc(allIri.(ep){i}, b);
% 
%         hTrip.(ep){i} = hTrip.(ep){i}./sum(hTrip.(ep){i});
%         hAll.(ep){i} = hAll.(ep){i}./sum(hAll.(ep){i});
        
%         hTrip.(ep){i} = smoothn(hTrip.(ep){i}, 2);
%         hAll.(ep){i} = smoothn(hAll.(ep){i}, 2);
    end
end


    f = figure;
    
    ax(1) = subplot(221);

    line(b, hTrip.sleep{1}, 'color', 'b', 'Parent', ax(1), 'linewidth', 2);
    line(b, hTrip.sleep{2}, 'color', 'r', 'Parent', ax(1), 'linewidth', 2)
    
    title('Sleep Triplets');
    legend('Peaks', 'Random');

    ax(2) = subplot(222);
    
    line(b, hAll.sleep{1}, 'color', 'b', 'Parent', ax(2), 'linewidth', 2);
    line(b, hAll.sleep{2}, 'color', 'r', 'Parent', ax(2), 'linewidth', 2);
    
    title('Sleep Ripples');
    
     ax(3) = subplot(223);

    line(b, hTrip.run{1}, 'color', 'b', 'Parent', ax(3), 'linewidth', 2);
    line(b, hTrip.run{2}, 'color', 'r', 'Parent', ax(3), 'linewidth', 2)
    
    title('Run Triplets');

    ax(4) = subplot(224);
    
    line(b, hAll.run{1}, 'color', 'b', 'Parent', ax(4), 'linewidth', 2);
    line(b, hAll.run{2}, 'color', 'r', 'Parent', ax(4), 'linewidth', 2);
    
    title('Run Ripples');

    set(ax,'XLim', [0 .25]);




    %% Fit the IRI distributions to an INVERSE GAUSSIAN distribution
    
    figure;
        
    ax = axes('NextPlot', 'add');
    X = allIri.sleep{i};
    X = X(X<.25);
    h = histc(X, b);
    h = smoothn(h, 2, 'correct', 1);
    h = h/max(h);
    
    line(b, h, 'Color', 'b', 'linewidth', 2,'Parent', ax); 
    
    probDistSleep = fitdist(X, 'gamma');
    pdfSleep = probDistSleep.pdf(b);
    pdfSleep = pdfSleep ./ max(pdfSleep);
    
    line(b, pdfSleep, 'color', 'k', 'linewidth', 2);









