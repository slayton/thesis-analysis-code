function thetaBand=filterTheta(eegData, Fs)
    N = ceil(Fs./4); 
    N = N + mod(N,2); 
    b = fir1( N, 2.*[6 12]./Fs ); 
    thetaBand = filtfilt(b,1,eegData);
   