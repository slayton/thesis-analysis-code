function idx = seg2binary(seg, ts)


segFilt = segmentfilter(seg);

inSegTs = segFilt(ts);

inSegIdx = interp1(ts, 1:numel(ts), inSegTs, 'nearest');

idx = false(size(ts));
idx(inSegIdx) = true;  



end