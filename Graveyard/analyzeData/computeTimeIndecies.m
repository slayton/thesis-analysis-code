function times = computeTimeIndecies(timestamps, start, stop)
% computerTimeindecies, returns the indexes with the FIRST timestamp after
% times, which is defined as [time1 time2] values in AD time, not in
% timestamps.  times is returned with the indexs as a .start and a .end


ind = find(timestamps>start*10000);
times.start = ind(1);

ind = find(timestamps>stop*10000);
times.end = ind(1);
%ind = find(p.timestamp>con.start*10000);
%con.startIND = ind(1);
%ind = find(p.timestamp>con.end*10000);
%con.endIND = ind(1);

%ind = find(p.timestamp>drug.start*10000);
%drug.startIND = ind(1);
%ind = find(p.timestamp>drug.end*10000);
%drug.endIND = ind(1);
