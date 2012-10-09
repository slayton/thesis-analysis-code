%% Calculate Average Ripple


exp = gh;
epochs = exp.epochs;
e_ch = 1;

%% 
clear m burst_data max_ind wb;

for e = epochs
    e = e{:};
    drawnow
    
    burst_win = find_rip_burst(exp.(e).eeg(e_ch).data, exp.(e).eeg_ts, exp.(e).eeg(e_ch).fs);

    
    n_samp = ceil(.5*750);
    rip_data = zeros(size(burst_win,1),n_samp);
   
    wb = my_waitbar(0);
    
    
    for i=1:size(burst_win,1)
        win_len = diff(burst_win(i,:));
        padding = (.5-win_len)/2;
        load_window = [burst_win(i,1)-padding, burst_win(i,2)+padding];
        burst_data = exp.(e).eeg(e_ch).load_window(load_window);

        %burst_n = length(burst_data);
        
       %max_ind = find(burst_data==max(burst_data));
       %delta = floor((n_samp-max_ind)/2);
       %disp(['delta:',num2str(delta),' burst_n:', num2str(burst_n), ' rip:',num2str(size(rip_data)),' i:' num2str(i)]);
        
        rip_data(i,:) = burst_data;
               
        wb = my_waitbar(i/size(burst_win,1),wb);
    end
    
    dout.(e) = rip_data;
    
end


%%

bs.control = boostrp(1000,@mean, dout.control);
bs.midazolam = bootstrp(1000,@mean, dout.midazolam);

%%
std_c = std(bs.control);
m_c = mean(bs.control);

std_m = std(bs.midazolam);
m_m = mean(bs.midazolam);

b = -.25:1/750:.25;
b = b(1:end-1);

plot(b, m_c, 'r', b, m_m, 'k', 'linewidth',2); hold on;
plot(b, m_c+2*std_c, '--r', b, m_c-2*std_c, '--r', b, m_m+2*std_m, '--k', b, m_m-2*std_m, '--k');
hold off;

%%
b = 0:.05:10;
isi.mid = histc(diff(gh.midazolam.rip_burst.windows(:,1)),b);
isi.con = histc(diff(gh.control.rip_burst.windows(:,1)),b);
isi.con_n = smoothn(isi.con / length(gh.control.rip_burst.windows),2);
isi.mid_n = smoothn(isi.mid / length(gh.midazolam.rip_burst.windows),2);


plot(b, isi.con_n, 'r',b,isi.mid_n, 'k', 'LineWidth', 2); 

%%
%%
clear rate;
for ep = gh.epochs;
    e = ep{:};
    bt = gh.(e).multiunit.burst_times;

    rate.(e).raw = 0;
    for i = 1:length(bt);
        b = bt(i,:);

        burst_rate = gh.(e).multiunit.rate(   ...
            gh.(e).multiunit.timestamps>=b(1) & ...
            gh.(e).multiunit.timestamps<=b(2) ...
        );
        rate.(e).mean(i) = mean(burst_rate);
    end
    rate.(e).total_mean = mean(rate.(e).mean);
    rate.(e).n = i;
end

%%

bs_mid = bootstrp(1000, @mean, rate.midazolam.mean);
bs_con = bootstrp(1000, @mean, rate.control.mean);


%%
























