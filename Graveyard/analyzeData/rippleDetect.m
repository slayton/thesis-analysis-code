function times = rippleDetect(eegThold, timestamps)
times = [];
count = 1;
for i=2:length(eegThold)
    if(eegThold(i)>0 & eegThold(i-1)==0)
        times(count) = timestamps(i);
        count = count+1;
    end;
end;


