function deltaBand=filterDelta(eegData, Fs)
    N = ceil(Fs./4); 
    N = N + mod(N,2); 
    b = fir1( N, 2.*[.1 5]./Fs ); 
    deltaBand = filtfilt(b,1,eegData);
   