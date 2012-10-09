%% Comparison of CA1 Cells in Saline and Midazolam



exp = cit;
ind = 27;
epochs = {'saline', 'midazolam'};
%%
for e = 1:numel(epochs);
    ep = epochs{e};
   
    clear corr lags dt coors
    dt = .005;
    cn = 0;
    for i = 1:numel(exp.(ep).clusters)
        
        cell = nephron12.(ep).clusters(i);
        if numel(cell.time)<10000 % remove interneurons
            disp([i numel(cell.time)])
            st = histc(cell.time, min(cell.time):dt:(max(cell.time)));
            [c lags] = xcorr(st, st, 100);
            cn = cn + 1;
            corr(cn,:) = c;%/sum(c);
        end
    end
    c_out{e} = corr;
end

%% View the ACorr of spiking without central peak, normalized

c_plot = [c_out{1}; c_out{2}];
size(c_out{1})

ind = (lags*dt)<-.05 | (lags*dt)>.05;
c_plot(:,~ind) = 0;
%c_plot = normalize(c_plot,1, 'mean');
mn = min(c_plot, [], 2);
mx = max(c_plot, [], 2);
mn = repmat(mn,1,size(c_plot,2));
mx = repmat(mx,1,size(c_plot,2));
figure;
imagesc(lags*dt,1:size(c_plot,1),(c_plot-mn)./mx);
%% Integrate each cells acorr from 50 to 300 ms
clear ind csal cmid csals cmids ms mm sem ses

ind = abs(lags*dt)<=.18 & abs(lags*dt)>.08;

csal = c_out{1};
csal(:,~ind) = 0;
cmid = c_out{2};
cmid(:,~ind) = 0;

csals = sum(csal,2);
cmids = sum(cmid,2);

ms = mean(csals);
mm = mean(cmids);

ses = std(csals)/sqrt(numel(csals));
sem = std(cmids)/sqrt(numel(cmids));

barerrorbar([1 2], [ms mm], 2*[ses sem]);
set(gca, 'XLim', [.5 2.5], 'XTickLabel', {'Saline', 'Midazolam'})
ylabel('Avg atocorrelation');

%% compare the average acorr across all cells by epoch saline vs midazolam
figure;
gca;
hold on;
for e= 1:numel(epochs)
    c = c_out{e};
    ind = (lags*dt)<-.05 | (lags*dt)>.05;
    c = smoothn(c, 1);
    
    c(:,~ind) = 0;
    mx = max(c,[],2);
    mx = repmat(mx,1,size(c,2));
    c = c./mx;
    ep = epochs{e};
    m = mean(c);
    sd = std(c);
    se = sd / sqrt(size(c,1));
    plot(lags, m, 'k', lags, m-se, '--r', lags, m+se, '--r');
end

%% Compare spatial information of cells by epoch
clear tc sis tc_n m se s

for e = 1:numel(epochs);
    ep = epochs{e};
    
    tc = get_tuning_curves(exp, ep);
    tc = sum(tc,3);
    s = sum(tc);
    s = repmat(s, size(tc,1),1);
    tc_n = tc./s;
    si = spatialinfo(tc_n');
    %si = si(find(si))
    sis{e} = si;
    m{e} = mean(sis{e});
    s = std(sis{e});
    se{e} = s/sqrt(size(si,1));
end
figure;
barerrorbar([1 2], cell2mat(m), cell2mat(se)*2)
set(gca, 'XLim', [.5 2.5], 'XTickLabel', {'Saline', 'Midazolam'})
ylabel('Bits per spikes');


    
    


%%
% only include cells that are valid PC
% Select cells that have a good PF
% select cells that have enough spikes 
% select cells based upon spatial information
% Take the acorr
% compare the acorr tails of midazolam vs saline
% 
% look for gamma modulation in the acorr
%
% it looks like the midazolam acorrs have a lower frequency and have and
% die out slower???  What causes this? I normalize and their rates are
% lower so it could be the result of that...