function cdat_r=filterLow(cdat)

    if cdat.samplerate > 2000
        disp ('Sample rate > 2000, interpolating down to 1000Hz');
        cdat = contresamp(cdat, 'resample', 2000/cdat.samplerate)
%        cdat = continterp(cdat, 'samplerate', 2000, 'method', 'cubic');
    end
    fopt_ripple = mkfiltopt('name', 'Low [ 10-30]', 'filttype', 'bandpass', 'F', [5 10 30 50]);
    cdat_r = contfilt(cdat,'filtopt', fopt_ripple);
    
    