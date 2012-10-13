function [spec, f, t] = my_spectrogram(data, win_len, TW, overlap_percentage, fs)

win_len = floor(win_len * fs);
n_overlap = floor(overlap_percentage*win_len);
n_points = length(data);
increment = win_len - n_overlap;
cur_ind = 1;
spec = [];

h = 

while cur_ind + win_len < n_points
    ind = (cur_ind:cur_ind+win_len-1)';
    [spec(:,end+1) f] = pmtm(data(ind), TW, win_len, fs);  
    cur_ind = cur_ind + increment;
end

spec = fliplr(spec);

t =  0 : (length(data)*1/fs)/length(spec) : (length(data)*1/fs);
t = t(1:end-1);




