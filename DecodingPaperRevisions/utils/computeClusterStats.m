function stats = computeClusterStats(clId, data)
%%

nTT = numel(clId);

stats = repmat(struct( 'nSpike', [],'lRatio', []), 1, nTT);

warning off; %#ok suppress mahal warning about precision
for iTT = 1:nTT
    
    if isempty(clId{iTT})
        continue;
    end
    
    clustId = clId{iTT};
    feat = data{iTT}( :, 1:4 );
    
    nClust = max(clustId);
   
    lr = nan(nClust,1);
    ns = nan(nClust,1);
    
    for iCl = 1:nClust
        
        clIdx = clustId == iCl;
        
        ns(iCl) = nnz(clIdx);
        
        if ns(iCl)<4
            continue;
        end
        [ lr(iCl) ] = lRatio(feat, clustId == iCl);
        
    end
    
    stats(iTT).nSpike = ns;
    stats(iTT).lRatio = lr;
    
end
warning on; %#ok
%%
end