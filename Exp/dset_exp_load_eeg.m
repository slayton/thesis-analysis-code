function [eeg, ref, channels] = dset_exp_load_eeg(edir, epoch)

ch = exp_get_preferred_eeg_channels(edir);

e = load_exp_eeg(edir, epoch);
fs = timestamp2fs(e.ts);

for i = 1:3
    eeg(i).data = e.data(:,ch(i));
    eeg(i).fs = fs;
    eeg(i).starttime = e.ts(1);
    eeg(i).area = 'CA1';
    eeg(i).hemisphere = 'right';
    eeg(i).tet = 'unknown';
end

ref = [];
