%%
clear eeg;
epochs = exp.epochs;
for ep = epochs
    e = ep{1};
    eeg.(e).data = nan(length(exp.(e).eeg(1).data),length(exp.(e).eeg));
    count =0;
    for i = 1:length(exp.(e).eeg)
        s = abs(exp.(e).eeg(i).data); 
        if ~(sum(s) <1e5  || max(isnan(s)) || max(isinf(s)) )
            count = count +1;
            eeg.(e).data(:,count) = exp.(e).eeg(i).data;
        end
    end
    eeg.(e).data = eeg.(e).data(:,1:count);
    eeg.(e).mean = mean(eeg.(e).data,2);
end