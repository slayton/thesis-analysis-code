


maxVal = 256;
x = randi(256, 10000, 1);

count = hist(maxVal, 0:maxVal);

prob = count ./ sum(count);

ent = -1 * sum( prob  .* log(prob))