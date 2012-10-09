function cdat_r=filterRipple(cdat)

    if cdat.samplerate > 2000
        disp ('Sample rate > 2000, reampleing down to 2000Hz');
        cdat = contresamp(cdat, 'resample', 2000/cdat.samplerate)
%       cdat = continterp(cdat, 'samplerate', 2000, 'method', 'cubic');
    end
    fopt_ripple = mkfiltopt('name', 'ripple', 'filttype', 'bandpass', 'F', [75 100 250 400]);
    cdat_r = contfilt(cdat,'filtopt', fopt_ripple);
    
    