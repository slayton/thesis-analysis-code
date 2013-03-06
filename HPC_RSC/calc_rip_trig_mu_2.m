function f = calc_rip_trig_mu_2(MU, HPC, fld, p)

win = [-.25 .75];
N = numel(MU);
Fs = timestamp2fs(HPC(1).ts);

ripSamp = {  };
IRI = [];
for i = 1 : N
    
%     mu = MultiUnit{i};
    if ~exist('p', 'var') || isempty(p)
        [ripIdx, ripWin] = detectRipples(HPC(i).ripple, HPC(i).rippleEnv, Fs, 'pos_struct', [], 'ts', HPC(i).ts);
    else
        [ripIdx, ripWin] = detectRipples(HPC(i).ripple, HPC(i).rippleEnv, Fs, 'pos_struct', p(i), 'ts', HPC(i).ts);
    end
    ripTs = HPC(i).ts(ripIdx);
 
    [startIdx, setLen, setId] = group_events(ripTs, [.5 .125]);
    
    evIdx = startIdx( setLen == 2 ); % get events with 2 ripples or more
    evLen = setLen( setLen == 2); % get lengths for events with 2 ripples or more
    evTs  = ripTs(evIdx);
    
    iri = [.5, diff(ripTs)];
    meanIri =[];
    
    for j = 1:numel(evIdx)
    
        r = iri( evIdx(j)+1 : evIdx(j)+evLen(j)-1 );
        meanIri(j) = mean(r);
    
    end
    
    slowIdx = meanIri > .075;
    fastIdx = meanIri < .075;
    slowTs = evTs( slowIdx );
    fastTs = evTs( fastIdx );
    
    fprintf('%d - nFast:%d nSlow:%d\n', i, numel(fastTs), numel(slowTs));
      
    [~, ts, ~, ripSamp{1,i}] = meanTriggeredSignal(slowTs, MU(i).ts, MU(i).(fld), win);
    [~, ts, ~, ripSamp{2,i}] = meanTriggeredSignal(fastTs, MU(i).ts, MU(i).(fld), win);

%     ripSamp{3,i} = ripSamp{1,i}(idx2,:);
%     ripSamp{4,i} = ripSamp{1,i}(idx3,:);
    
    %     [ctxTrip(i,:), ts] = meanTriggeredSignal(setTs, mu.ts, mu.ctx, win);
    %     [ctxSolo(i,:), ts] = meanTriggeredSignal(soloTs, mu.ts, mu.ctx, win);
    
    
end
fprintf('\n');

%%
f = figure;
ax = axes('NextPlot', 'add');
T = ts * 1000;
c = [0 0 0; .5 0 0; 0 .5 0; 0 0 .5];
[pt, l] = deal([]);

for i = [1 2]
     r = cell2mat({ ripSamp{i,:}}');
    
    for j = 1:size(r,1)
        rr = r(j,:);
        rr = rr - min(rr);
        rr = rr / max(rr);
        r(j,:) = rr;
    end
    
   
    
    m = mean(r);
    e = std(r) * 1.96 / sqrt( size(r,1) );
    
    [pt(i), l(i)] = error_area_plot(T, m, e, 'Parent', ax);
    set(pt(i),'EdgeColor', 'none', 'FaceColor', c(i,:) + .4);
    set(l(i), 'color', c(i,:));
    
    [~, mIdx] = findpeaks(m);
    
    mTs = T(mIdx);
    mTs = mTs(mTs > 0 & mTs < 100);
    for j = 1:numel(mTs)
        line( mTs(j) * [1 1], [min(m), max(m)], 'color', 'k');
    end
    
    set(gca,'XTick', unique([get(gca,'XTick'), mTs]) );
    
end


set(ax,'Xlim', [-200 300]);

% plot2svg( sprintf('/data/HPC_RSC/ripple_triggered_%s_mu.svg', upper(fld)) ,gcf);

end
