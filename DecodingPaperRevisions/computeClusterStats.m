function stats = computeClusterStats(baseDir)
%%
[clId, data] = load_clusters_for_day(baseDir);

nTT = numel(data);

stats = repmat(struct( 'nSpike', [],'lRatio', []));
for iTT = 1:nTT
    
    clustId = clId{iTT};
    amp = data{iTT}( :, 1:4 );
    
    nClust = max(clustId);
   
    lr = nan(nClust,1);
    ns = nan(nClust,1);
    
    for iCl = 1:nClust
        
        clIdx = clustId == iCl;
        
        ns(iCl) = nnz(clIdx);
        
        if ns(iCl)<4
            continue;
        end
        lr(iCl) = lRatio(amp, clustId == iCl);
        
    end
    stats(iTT).nSpike = ns;
    stats(iTT).lRatio = lr;
    
end
%%
end