function filtered_vector =filterBand(eegData, Fs, band)
% filterBand(signal, Fs, band)
% returns the original signal but filtered.
% signal = the signal
% Fs = the samples rate of the signal
% band = [x y] where x is the highpass freq and y is the low pass freq
    N = ceil(Fs./4); 
    N = N + mod(N,2); 
    b = fir1( N, 2.*band./Fs ); 
    filtered_vector = filtfilt(b,1,eegData);
   