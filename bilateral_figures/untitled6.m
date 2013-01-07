K = 100000;
N = 50;

d = [];
bins = 0:50;
for i = 1:N
    x = mod(randi(1e6, K, 1), i);
    d(i,:) = normr(hist(x, bins));
end

