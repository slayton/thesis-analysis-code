cl = eric.run.cl;
p = eric.run.pos;

st = [];
id = [];
spikeCount = 1;
for i =1:numel(cl)
    st = [data; cl(i).st(:)];
    id = [id; ones(size(cl(i).st(:))) * i];
end
lp = interp1(p.ts, p.lp, st);
x = interp1(p.ts, p.xp, st);
y = interp1(p.ts, p.yp, st);
        
[~, idx] = sort(st);

forEric = [st(idx), id(idx), lp(idx), x(idx), y(idx)];