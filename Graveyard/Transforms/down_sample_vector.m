function [data, times] = down_sample_vector(data, times, fs_old, fs_new)
    if fs_old<=fs_new
        return
    else
       data = filterBand(double(data), fs_old, [.01, fs_new/2]);
       data = downsample(data, ceil(fs_old/fs_new));
       times = downsample(times, ceil(fs_old/fs_new));
    end
end