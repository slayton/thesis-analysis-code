clear;
edir = '/data/gh-rsc1/day18';

epList = load_epochs(edir);

for i = 1:numel(epList)
    
    ep = epList{i};
    fName = fullfile(edir, sprintf('MU_HPC_RSC_%s.mat', upper(ep)));
    
    if exist(fName, 'file')
        fprintf('%s already exists, skipping it!\n');
        continue;
    end
    
    mu = dset_exp_load_mu_all(edir, ep);
    
    save( fName, 'mu');
    fprintf('%s SAVED!\n', fName);
end
    
