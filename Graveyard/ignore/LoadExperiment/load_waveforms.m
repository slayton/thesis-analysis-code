function [mean_wave wave_height waves] = load_waveforms(tt_file, cl_file)
% wave = LOAd_WAVEFORMS(tt_file, cl_file)
%   returns the average waveform across all 4 channels given a 
%   tt_file and a corresponding cluster file 

   % gains = load_gains(tt_file);
  
    if  exist(cl_file,'file')
        data = load(mwlopen(cl_file), 'id');
    
        data = load(mwlopen(tt_file), {'waveform'}, data.id);
    else
        data = load(mwlopen(tt_file), {'waveform'});
    end
    mean_wave = mean(data.waveform,3);
    wave_height = max(max(data.waveform));
    wave_height = wave_height(:);
    wave = data.waveform;
    %gains = repmat(gains, 1,length(data.waveform));
    %wave = ad2mv(data.waveform, gains);
    waves = data.waveform
end
