function s = exp_load_sleep(edir)

dList = {'/data/spl11/day12', '/data/spl11/day15'};
eList = {'sleep3', 'sleep2'};

idx = find(strcmp(edir, dList));
if isempty(idx)
    error('Undefined edir');
end

r = exp_load_run(edir, 1);

s = exp_load(edir, 'epochs', eList{idx}, 'data_types', {'clusters'});

clRun = r.run.cl;
clSleep = s.(eList{idx}).cl;

if numel(clRun) ~= numel(clSleep)
    error('Epochs Run and Sleep have a different number of clusters');
end

for i = 1:numel(clSleep)
    clSleep(i).tc1 = clRun(i).tc1;
    clSleep(i).tc2 = clRun(i).tc2;
    clSleep(i).tc_bw = clRun(i).tc_bw;
end

s.(eList{idx}).cl = clSleep;

s = process_loaded_exp2(s, [2 4 7]);


if ~strcmp(eList{idx}, 'sleep')
    s.sleep = s.(eList{idx});
    s = rmfield(s, eList{idx});
end