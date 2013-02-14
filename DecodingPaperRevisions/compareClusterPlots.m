function plotClusters(baseDir)
%%
[cl, data, ttList] = load_clusters_for_day(baseDir);
nTT = numel(cl);

for iTetrode = 2:nTT
    
    fprintf('Evaluating TT:%d\n', iTetrode);
    
    clId = cl{iTetrode};
    ts = data{iTetrode};
    
    nCl = max(clId);
    if nCl < 2
        continue;
    end
    
    %Pre compute the timebin range
    tRange = cell2mat( cellfun(@(x) (minmax(x(:,5)')), data, 'uniformoutput', 0)' );
    tbins = min(tRange(:,1)) :.001: max(tRange(:,2));
    
    %Pre compute the spike rate for each cluster
    fprintf('Computing rates:');
    rate = zeros(nCl, numel(tbins));
    for iCl = 1:nCl
        rate(iCl,:) = histc( data{iTetrode}(clId == iCl,5), tbins );
        fprintf('%d ', iCl);
    end
    fprintf('\n');
    
    fprintf('Computing xcorr:');
    % Precompute the xcorr spike rates
    xc = cell(nCl, nCl);
    for iCl = 1:nCl
        for jCl = iCl+1:nCl
            xc{iCl, jCl} = xcorr(rate(iCl,:), rate(jCl,:), 50);
        end
        fprintf('%d ', iCl);
    end
    fprintf('\n');
    
    fprintf('Plotting the correlations\n');
    % Render the xcorrs
    figure('Name', sprintf('%s - %s', baseDir, ttList{iTetrode}), 'Position', [0 300 900 800] + iTetrode * [30 -30 0 0 ]);
    
    nCl = 5;
    nAx = nCl - 1;
    
    axH = tight_subplot(nAx, nAx, [.05 .02],[.05 .01],[.01 .01]);
    %         axH = reshape(axH, nAx, nAx);
    
    axCount = 0;
    for iAx = 1 : nAx
        iCl = iAx;
        
        for jAx = 1 : nAx
            jCl = jAx+1;
            
            axCount = axCount + 1;
            
            if jCl <= iCl
                delete( axH(axCount) );
            else
                
            
            line(-50:50, xc{iCl, jCl},  'Parent', axH(axCount))
            title(axH(axCount), sprintf('%d x %d',iCl, jCl));
            set(axH(axCount),'XTick', [-50 0 50],'YTick',[], 'XLim', [-50 50]);
            
            end
        end
    end
    
end

end