function stats = computeClusterStats(baseDir, ttList)
%%
[clId, data] = load_clusters_for_day(baseDir);

nTT = numel(data);

if nargin==1
    ttList = 1:nTT;
end

stats = repmat(struct( 'nSpike', [],'lRatio', []), 1, nTT);

for iTT = ttList
    
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
        [ lr(iCl) ] = lRatio(amp, clustId == iCl);
        
    end
    stats(iTT).nSpike = ns;
    stats(iTT).lRatio = lr;
    
end


stats = stats(ttList);

%%
end