function [a, pc] = load_dataset_features(baseDir, nChan)

klustDir = fullfile(baseDir, 'kKlust');


dsetFile = sprintf('%s/dataset_%dch.mat', klustDir, nChan);
in = load(dsetFile);

ts = in.ts;
amp = in.amp;
lp = in.lp;
lv = in.lv;
w = in.width;
pc = in.pc;

a = {};
for i = 1:numel(ts)
   
    data = [amp{i}, ts{i}, lp{i}, lv{i}, w{i}(:)];
    a{end+1} = data;
end
    


end