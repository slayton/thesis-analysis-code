function chans = exp_get_preferred_eeg_channels(eDir)
    
[rem, day] = fileparts(eDir);
[~, ani] = fileparts(rem);

id = [ani,'-',day]


switch id
    case 'spl11-day11'
        chans  = [ 9 10 3];
    case 'spl11-day12'
        chans = [11 12 2];
    case 'spl11-day13'
        chans = [9 8 2];
    case 'spl11-day14'
        chans = [12 11 4];
    case 'spl11-day15'
        chans = [11 12 3];
    case 'spl11-day16'
        chans = [11 12 3];    
    case 'gh-rsc1-day18'
        chans = [14 15 16];
end

end