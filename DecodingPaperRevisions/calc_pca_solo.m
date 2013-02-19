function d = calc_pca_solo(wf)

    if ndims(wf)<3
    
        error('Invalid waveforms');
    end
    
    nChan = size(wf,1);

    d = [];
    for iChan = 1:nChan
            w = squeeze(wf(iChan,:,:))';

            [~, s] = pca(w, 'NumComponents', 3);
            d = [d, s];
    end

end