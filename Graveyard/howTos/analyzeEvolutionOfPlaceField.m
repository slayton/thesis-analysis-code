%Compute place field evolution over time?
%import the data and set the epoch
cells = cellsD;
runCont= [7106.353 7800.5522];  %These values are only for data/dan/09.11.0
runDrug= [7800.5522   9395.2490];
epoch = runDrug;
p = position;

%truncate position data into seconds:
p.timestamp = double(p.timestamp)/10000.0;

%interpolate zero positions:
len = length(p.xfront);
for i=2:len-1;
    if p.xfront(i)==0 || p.yfront(i)==0 || p.xback(i)==0 || p.yback(i)==0
        disp('Found 0 position, averaging with adjacent samples');
        p.xfront(i) = (p.xfront(i-1) + p.xfront(i+1))/2;
        p.yfront(i) = (p.yfront(i-1) + p.yfront(i+1))/2;
        p.xback(i) = (p.xback(i-1) + p.xback(i+1))/2;
        p.yback(i) = (p.yback(i-1) + p.yback(i+1))/2;
    end;
end;
    
%Find the indexes of records that correspond to the desired epoch
selEpochIndex = selectByTimes(p.timestamp, epoch(1), epoch(2));
pos = p;
%remove records from outside the epoch from the position data
pos.timestamp = pos.timestamp(selEpochIndex);
pos.xfront = pos.xfront(selEpochIndex);
pos.yfront = pos.yfront(selEpochIndex);
pos.xback  = pos.xback(selEpochIndex);
pos.yback  = pos.yback(selEpochIndex);

%determine a location for crossings.... and get timestamps of crossing
%calculate crossing by grabbing 2 records, detemining if they are areu
%differnt sides of the crossing point, if they are take the timestamp of
%the latter record

xFbar = mean(pos.xfront);
xBbar = mean(pos.xback);
yFbar = mean(pos.yfront);
yBbar = mean(pos.yback);

crossing = xFbar; % select the diode to use
% Change below if the above value is changed
crossingTimes=[];
count=1;

%This code is buggy and is grabbing more crossings then it should I don't
%know if this is because the data is noisy or the algorithm is bad, i
%really don't know and frankly I don't care right now
tick=0;
for i = 1:length(pos.xfront)-1;
    tick=tick+1;
    if mod(i,1000)==0
        disp(i);
    end;
    check = [pos.xfront(i) pos.xfront(i+1)];
    if tick>250 && min(check)<= crossing && max(check)> crossing
        crossingTimes(count) = pos.timestamp(i+1);
        count=count+1;
        tick=0;
    end;
end;

% Take the individual crossings and create laps
laps=[];
for i=1:length(crossingTimes)-1;
    laps(i).start = crossingTimes(i);
    laps(i).end = crossingTimes(i+1);
end;

%create spike container for each lap
for cellNum=1:length(cells)       %  --------- THIS FOR LOOP IS TO DO ANALYSIS ON ALL THE CELLS THAT HAVE BEEN CLUSTED REMOVE THIS AND LAST END TO DO INDIVIDUAL ANALYSIS
    %cellNum = i;
    cell = cells(cellNum);
    clear spikes;
    clear aveField;
    aveField.px = [];
    aveField.py = [];
    clear spikes;  %this variable contains the individual spikes for one l
    for i=1:length(laps);
        % grab only spikes within the window
        spikeIndex = selectByTimes(cell.times, laps(i).start, laps(i).end);
        spikes(i) = cell;
        spikes(i).id = spikes(i).id(spikeIndex);
        spikes(i).times = spikes(i).times(spikeIndex);
        spikes(i).px = spikes(i).px(spikeIndex);
        spikes(i).py = spikes(i).py(spikeIndex);
        spikes(i).velocity = spikes(i).velocity(spikeIndex);
        if length(spikeIndex>5)
            aveField.px = [aveField.px  spikes(i).px'];
            aveField.py = [aveField.py  spikes(i).py'];
        end;
    end;

    %
    % TO DO
    % TO DO
    % Include code that computes the place field based upon the first and
    % second halves. Examin to see if a difference exists between the mass of
    % the first half and the mass of the 2nd half.... then see how cells in the
    % early part of run correspond to to the field of the 1st half and dido
    % for the 2nd half

    % Compute average place field, and center of mass
    fieldHist = hist(aveField.px, 1:1:213);
    fieldMax = max(fieldHist);
    fieldSum = sum(fieldHist);
    a = ones(length(fieldHist),1);
    for i=1:length(fieldHist)
        a(i)=(fieldHist(i)*i)/fieldSum; 
        fieldCenterMass = sum(a);
    end;

    figure; hist(aveField.px, 1:1:213); title(strcat('Complete Place field of cell: ', int2str(cellNum), ' across all runs'));hold on; plot(fieldCenterMass, 10, 'r.');hold on;



    % plot each lap with more then 10 spikes as a histogram, overlay average
    % place field 
    clear allLapsHist;
    plotAll = 0;
    tick=0;
    for i=1:length(spikes);
        if length(spikes(i).id)>10
            tick=tick+1;
            h = hist(spikes(i).px, 1:1:213);    % histogram of the neural activity of one lap
            allLapsHist(tick,:) = h;
            if (plotAll==1)
                figure; plot(1:1:213, smoothn(fieldHist*(max(h)/fieldMax),1), 'r'); hold on;
                hist(spikes(i).px, 1:1:213);
                hobj = findobj(gca,'Type','patch'); % set the color on this histogram
                set(hobj,'FaceColor','b','EdgeColor','b') % again setting the color
                xLine = [fieldCenterMass fieldCenterMass];
                yLine = [0 max(h)];
                line(xLine, yLine, 'LineStyle', '--', 'color', 'k'); % plot the center of the placefield across ALL laps
                title(strcat('Sinlge Unit activity of lap:', int2str(i), ' Cell number:', int2str(cellNum)));
            end;
        end;
    end;

    % plot allLapsHist in 3d to examine the evolution of the placefield over
    % the laps....
    if (exist('allLapsHist'))
        figure;
        clear mini;
        clear maxi;
            for i=1:min(size(allLapsHist))
                y = allLapsHist(i,:);
            y = smoothn(y,2);
            mini(i) = find(allLapsHist(i,:), 1 );  %store the _FIRST_ Position where a spike occurs for the lap
            maxi(i) = find(allLapsHist(i,:), 1, 'last' ); % store the _LAST_ position where a spikes occurs for the lap
            y(end) = i/20;
            x = 1:length(y);
            z = ones(length(x),1)*i;
            plot3(z,x,y); hold on;
        end;
        z= ones(length(mini),1);
        x = 1:length(mini);
        plot3(x, mini, z, 'r.'); hold on;
        plot3(x, maxi, z, 'g.'); hold on;
        miniR = [(1:length(mini))', ones(length(mini),1)]\mini'; % Calculate the regression line for the minimums
        maxiR = [(1:length(maxi))', ones(length(maxi),1)]\maxi'; % Calculate the regression line fot the maximums
        rLineMini = (1:length(mini))*miniR(1)+miniR(2);
        rLineMaxi = (1:length(maxi))*maxiR(1)+maxiR(2);
        plot3(x,rLineMini,z,'r'); hold on;
        plot3(x,rLineMaxi,z,'g'); hold on;
        title(strcat('Field for cell:', int2str(cellNum)));
    end;

end; % ------------- Remove this END if you removed the for loop above!