function exp = process_loaded_eeg(exp)

rhil = calculate_ave_hilbert(exp);
for ep = exp.epochs   
    e = ep{1};
    exp.(e).r_hil_ave = smoothn(rhil.(e), .0125, 1/500);
end
times = find_ripple_times(exp);
for ep = exp.epochs
    e = ep{1};
    exp.(e).ripple_times = times.(e);
end


evaluate_eeg(exp);
session_dir = exp.session_dir;

data = load(fullfile(session_dir, 'valid_eeg_chans.mat')); 
for e = exp.epochs
    epoch = e{:};
    exp.(epoch).eeg = exp.(epoch).eeg(data.valid_chan);
end

