function d = compute_pc_for_waves(wf)

    if ndim(wf)<3
        error('Invalid waveforms');
    end
    nChan = size(wf,1);

    for iChan = 1:nChan
            w = squeeze(wf(iChan,:,:))';

            [~, s] = pca(w, 'NumComponents', 3);
            d = [d, s];
    end

end