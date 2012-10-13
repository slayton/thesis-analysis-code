function plot_coherogram(cxy, f, t, min_f, max_f)
ind = find(f>=min_f & f<=max_f);
imagesc(t, f(ind), cxy(ind,:));
set(gca, 'YDir', 'Normal');
xlabel('Time'); ylabel('Frequency');
