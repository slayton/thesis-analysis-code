function [cxy, f, t] = my_coherogram(data1, data2, win_len, overlap_percentage, fs)
win_len = floor(win_len * fs);
n_overlap = floor(overlap_percentage*win_len);
n_points = length(data1);
increment = win_len - n_overlap;
cur_ind = 1;
cxy = [];

while cur_ind + win_len < n_points
    ind = (cur_ind:cur_ind+win_len-1)';
    [cxy(:,end+1) f] = cpsd(data1(ind), data2(ind), [], [], [], fs);
    cur_ind = cur_ind + increment;
end
%cxy = fliplr(cxy);
t =  linspace(1,numel(data1), size(cxy,2))/fs;





