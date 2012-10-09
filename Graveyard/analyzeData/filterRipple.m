function ripples=filterRipple(eegData, Fs)
    N = ceil(Fs./4); 
    N = N + mod(N,2); 
    b = fir1( N, 2.*[140 250]./Fs ); 
    ripples = filtfilt(b,1,eegData);
   