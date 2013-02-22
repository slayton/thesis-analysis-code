function [w, highIdx, lowIdx] = calc_waveform_width(wave)

    highIdx = [];
    lowIdx = [];
    
    if ndims(wave)==3
        
        for i = 1:size(wave,1)
            
            W = squeeze( wave(i,:,:));

            [~, highIdx(i,:)] = max( W(5:12,:) );
            [~, lowIdx(i,:)] = min( W(13:32,:) );
            
        end
            
    end
    
    highIdx = highIdx + 4;
    lowIdx = lowIdx + 12;
    w = lowIdx - highIdx;
    
    if size( wave, 1) == 1
        w = w';
    end
    
    
end