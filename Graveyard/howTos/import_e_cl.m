

for i=1:length(e.cl)
    cellsTom(i).times = e.cl(i).dat(:,1);
    cellsTom(i).id = e.cl(i).dat(:,2);
    
    posi = e.cl(i).dat(:,3);
    cellsTom(i).pos = e.pos.dat(posi,20);
end;

dt = 0.033;
for i=1:length(cellsTom)
   
    field = calculatePlaceField(cellsTom(i).pos, int16(e.pos.dat(:,20)), dt, 0 , 0 , 0);
    cellsTom(i).field = field;
   % figure; area(smoothn(field,10));
    
end;

tau = .01;
tMin = e.pos.dat(1,1);
tMax = e.pos.dat(end,1);
col = 0;
tCur = tMin;

tuningCurves = zeros(max(size(cellsTom(1).field)), length(cellsTom));
for i=1:length(cellsTom)
    tuningCurves(:,i) = cellsTom(i).field;
end;

posPdf = zeros(length(cellsTom(1).field), int16((tMax-tMin)/tau));
while tCur<tMax
    disp(strcat(int2str(cols), ' cols'));
    nSpikes = zeros(length(cellsTom),1);
    for i=1:length(cellsTom)
        nspikes(i) = sum(find(selectByTimes(cellsTom(i).times, tCur, tCur+tau)));
    end;
    pdf = parameter_estimation(tau, tuningCurves, nSpikes', 0);
    posPdf(:,cols) = pdf;
    cols = cols+1;
    tCur = tCur+tau;
end;
    
    