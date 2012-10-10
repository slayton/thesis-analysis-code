function d = dset_load_ripples(epoch, ref)

epoch = lower(epoch);

if ~ any( strcmp( {'run', 'sleep'}, epoch ) )
    error('Invalid epoch type specified: %s', epoch)
end

if nargin==1
    ref = 1;
end

refStr = '';
if ref==0
    refStr = 'NO_REF_';
end

file = sprintf('/data/franklab/bilateral/ALL_RIPS_%s%s.mat', refStr, upper(epoch));
d = load(file);
d = d.(epoch);
