function idx = seg2binary(seg, ts)


tmpFun = @(x) (x >= seg(:,1)  & x<=seg(:,2));

idx = arrayfun(tmpFun, ts, 'UniformOutput', 0 );
idx = cell2mat(idx);
idx = logical(sum(idx));

% segFilt = segmentfilter(seg);
% 
% inSegTs = segFilt(ts);
% 
% inSegIdx = interp1(ts, 1:numel(ts), inSegTs, 'nearest');
% 
% idx = false(size(ts));
% idx(inSegIdx) = true;  



end