function times = find_ripple_times(exp)
   
    epochs = exp.epochs;   
      
    for ep = epochs;
        
        e = ep{1};
        
        m_h = mean(exp.(e).r_hil_ave);
        s_h =  std(exp.(e).r_hil_ave);
       
        thold = exp.(e).r_hil_ave>(m_h+4*s_h);
        
        tx = logical2seg(thold); % treshold crossing indexes
        ripple_times = nan(1,length(tx));
        for i=1:length(tx)
            ind = tx(i,1):tx(i,2);
            ripple_times(i) = find(exp.(e).r_hil_ave(ind) == max(exp.(e).r_hil_ave(ind)), 1); %index from start of ripple
            ripple_times(i) =  exp.(e).eeg_ts(tx(i,1)+ripple_times(i));
        end
        times.(e) = ripple_times;
    end
end
