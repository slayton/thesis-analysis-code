function stats = computeClusterStats(clId, data, pcaFlag)
%%

if nargin==2
    pcaFlag = 0;
end

nTT = numel(clId);
stats = repmat(struct( 'nSpike', [],'lRatio', []), 1, nTT);

warning off; %#ok suppress mahal warning about precision
for iTT = 1:nTT
   
    if isempty(clId{iTT}) || isempty(data{iTT})
        stats(iTT).lRatio = nan;
        stats(iTT).nSpike = nan;
        continue;
    end
    
    clustId = clId{iTT};
    
    if pcaFlag
        feat = data{iTT};
    else
        feat = data{iTT}( :, 1:4 );
    end
    
    nClust = max(clustId);
   
    lr = nan(nClust,1);
    ns = nan(nClust,1);
    
    for iCl = 1:nClust
        
        clIdx = clustId == iCl;
        
        ns(iCl) = nnz(clIdx);
        
        if ns(iCl)<4
            continue;
        end
       
        if  nnz(clustId == iCl) > size(feat,2)
            lr(iCl) = lRatio(feat, clustId == iCl);
        else
            lr(iCl) = nan;
        end
        
    end
    
    stats(iTT).nSpike = ns;
    stats(iTT).lRatio = lr;
    
end
warning on; %#ok
%%
end