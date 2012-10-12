function d = dset_load_ripples(epoch)

if nargin==0
    epoch = 'all';
end

epoch = lower(epoch);


if ~ any( strcmp( {'run', 'sleep', 'all'}, epoch ) )
    error('Invalid epoch type specified: %s', epoch)
end

file = sprintf('/data/franklab/bilateral/all_ripples.mat');
d = load(file);

if strcmp(epoch, 'all')
    d = d.data;
else
    d = d.data.(epoch);
end
