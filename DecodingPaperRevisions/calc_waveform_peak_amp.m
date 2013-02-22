function pk = calc_waveform_peak_amp(waveform)

    if ndims(waveform) ~= 3
        error('waveform must be a MxNxP matrix')
    end
    
    pk = squeeze( max(waveform, [], 2) );
    
    % If the input is a single channel transpose pks so its oriented the
    % same as data with multiple channels
    if size(waveform,1) == 1
        pk = pk';
    end

end