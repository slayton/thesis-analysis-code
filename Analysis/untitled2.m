data =d ;
data.midazolam = data.midazolam / sum(data.midazolam);
data.saline = data.saline / sum(data.saline);
bins = linspace(-pi,pi, 36);

figure; 
plot(bins, smoothn(data.midazolam,2), 'k', bins, smoothn(data.saline,2), 'r');
%%

data = data_sl06;

figure; 
subplot(4,1,1:3);
hold on;

d1 = data.midazolam;
d1.mean = smoothn(d1.mean,1);
d1.std = smoothn(d1.std,1);

d2 = data.saline;
d2.mean = smoothn(d2.mean,1);
d2.std = smoothn(d2.std,1);


%patch([bins, fliplr(bins)], [d1.mean + d1.std, fliplr(d1.mean - d1.std)], 'r', 'edgecolor', 'r');
%patch([bins, fliplr(bins)], [d2.mean + d2.std, fliplr(d2.mean - d2.std)], 'k', 'edgecolor', 'k');
plot(bins, d1.mean, 'r', 'LineWidth', 2);
plot(bins, d2.mean, 'k', 'LineWidth', 2);

plot(bins, d1.mean+2*d1.std, 'r--', 'LineWidth', 2);
plot(bins, d1.mean-2*d1.std, 'r--', 'LineWidth', 2);

plot(bins, d2.mean+2*d2.std, 'k--', 'LineWidth', 2);
plot(bins, d2.mean-2*d2.std, 'k--', 'LineWidth', 2);

set(gca, 'XTick', []); 
ylabel('P Spike');

legend('midazolam', 'saline');
hold off;

subplot(414);
plot(bins, -1*cos(bins));
set(gca, 'YTick', [], 'XTickLabel',{'-pi','-pi/2','0','pi/2','pi'} );
xlabel('Ripple Phase');
%%


figure; gca; hold on;
plot(bins, d1.mean, 'r', 'linewidth',2);
plot(bins, d2.mean, 'k', 'linewidth',2);

patch([bins, fliplr(bins)], [d1.mean + d1.std, fliplr(d1.mean - d1.std)], 'r', 'edgecolor', 'r');
patch([bins, fliplr(bins)], [d2.mean + d2.std, fliplr(d2.mean - d2.std)], 'k', 'edgecolor', 'k');