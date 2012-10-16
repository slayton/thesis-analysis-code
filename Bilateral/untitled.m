tmp = dset_load_all('Bon', 4, 2);
tmp = dset_get_ripple_events(tmp);

winIdx = round([-.2 .2] * tmp.eeg(1).fs);
window = winIdx(1):winIdx(2);

dt = tmp.eeg(bc).fs;
st = tmp.eeg(bc).starttime;
ts = st + (0:(nSamp-1))*dt;

ripTs = tmp.ripples.peakTs;
ripPeakIdx = interp1(ts, 1:numel(ts), ripTs);

ripWin = bsxfun(@plus, ripPeakIdx, window);


tmpWaves1 = dset.eeg(1).data(ripWin);
tmpWaves2 = dset.eeg(3).data(ripWin);
