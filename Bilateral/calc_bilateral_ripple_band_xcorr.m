function [results] = calc_bilateral_ripple_band_xcorr(epoch)

if ~any( strcmp( epoch, {'sleep', 'run'} ) )
    error('Invalid epoch');
end


eList = dset_list_epochs(epoch);


for i = 1:size(eList,1)
    dset = dset_load_all(eList{i,1}, eList{i,2}, eList{i,3});
%    dset = dset_add_ref_to_eeg(dset);
    
    [xcIpsi(:,i) xcCont(:,i)] =  dset_analyze_xcorr_ripple_band(dset,1);
    if ~exist('eeg_fs', 'var')
        eeg_fs = dset.eeg(1).fs;
    end
end

results.xcorrIpsi = xcIpsi;
results.xcorrCont = xcCont;
% 
% %%
% for i = 1:size(eSleep,1)
%     dset = dset_load_all(eSleep{i,1}, eSleep{i,2}, eSleep{i,3});
%     [xcIpsi(:,i) xcCont(:,i)] =  dset_analyze_xcorr_ripple_band(dset,1);
% end
% 
% sleep.xcIpsi = xcIpsi;
% sleep.xcCont = xcCont;
% 
% %%
% if plotting==1
%     xcContNRun = bsxfun(@rdivide, run.xcCont, sum(run.xcCont));
%     xcIpsiNRun = bsxfun(@rdivide, run.xcIpsi, sum(run.xcIpsi));
%     
%     xcContNSleep = bsxfun(@rdivide, sleep.xcCont, sum(sleep.xcCont));
%     xcIpsiNSleep = bsxfun(@rdivide, sleep.xcIpsi, sum(sleep.xcIpsi));
% 
%     tbins = 1:size(xcContNRun,1);
%     tbins = tbins - ceil( tbins(end) / 2);
%     tbins = tbins / eeg_fs;
%     
%     figure;
%     subplot(211);
%     plot(tbins, mean(xcContNRun,2),'r');
%     hold on;
%     plot(tbins, mean(xcIpsiNRun,2),'k');
%     hold off;
%     
%     subplot(212);
%     plot(tbins, mean(xcContNSleep,2),'r');
%     hold on;
%     plot(tbins, mean(xcIpsiNSleep,2),'k');
%     hold off;
%         
%     legend({'Contralateral', 'Ipsilateral'});
% end

end