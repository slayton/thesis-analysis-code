function dset = dset_exp_load(edir, epoch)

if strcmp(epoch, 'run')
    e = exp_load_run(edir, [1 7]);
elseif strcmp(epoch, 'sleep')
    e = exp_load_sleep(edir, [1 7]);
end
  
dset = exp2dset(e, epoch);
dset.description.isexp = 1;
    
    
    