function d = calc_waveform_princom(wf, nChan)

    if size(wf,3) == 0
        d = [];
        return;
    end
    
    if nargin == 1
        nChan = 4;
    end

    if ndims(wf)~=3
        error('Invalid waveforms, must be a MxNxK matrix');
    end
    
    nPC = 3;
    d = nan( size(wf,3), nChan * nPC );
    colIdx = 1:3;

    for iChan = 1:nChan
        
            wSingleChan = squeeze(wf(iChan,:,:))';

            [~, s] = pca( wSingleChan , 'NumComponents', nPC);
            d( :, colIdx ) = s; 
            
            colIdx = colIdx + 3;
            
    end

end
