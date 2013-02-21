function d = calc_pca_single(wf)
    
    if ndims(wf)<3
    
        error('Invalid waveforms');
    end
    
    nChan = size(wf,1);

    d = [];
    for iChan = 1%:nChan
            w = squeeze(wf(iChan,:,:))';

            [~, s] = pca(w, 'NumComponents', 4);
            d = [d, s];
    end
    
%     if ndims(wf)<3
%         error('Invalid waveforms');
%     end   
% 
%     wf = permute(wf, [2,1,3]);
%     sz = size(wf);
%     wf = reshape(wf, sz(1)*sz(2),sz(3))';
%     
%     d = pca(wf,'NumComponents', 12);
% 
end