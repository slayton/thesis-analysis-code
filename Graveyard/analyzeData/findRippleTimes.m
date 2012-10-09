function times = findRippleTimes(rippleData, rippleTimestamps, dt)
% findRippleTimes(filteredData, dataTimestamps, dt)
% returns the timestamps of when ripples occur.
% dt can be used to timeout from one ripple to the next
% a minimum of 30 ms as a single ripple is atleast this long and a shorter
% dt then this might cause a single ripple to be counted twice
%
% preforms the hilbert transform and then finds where the hilbert transform
% is greater then 3 stdevs above the mean

h = abs(hilbert(rippleData));
mu = mean(h);
stdev = std(h);
thold = mu+3*stdev;
tholdR = h>thold;

times = zeros(10000,1);
count = 1.00;
for i=2:length(tholdR)
    if(tholdR(i)~=0 && tholdR(i-1)==0) 
    %if thold, and prev sample not thold then new ripple detected
        if count==1
            times(count) = rippleTimestamps(i);
            count = count+1;
        elseif  times(count-1)+dt<rippleTimestamps(i)
            times(count) = rippleTimestamps(i);
            count = count+1;        
        end
    end;    
end;
times = times(1:count-1);



