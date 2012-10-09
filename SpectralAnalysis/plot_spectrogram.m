function plot_spectrogram(s, f, t, min_f, max_f)
ind = find(f>=min_f & f<=max_f);
%figure;
imagesc(t, f(ind), log(s(ind,:)));
set(gca, 'YDir', 'Normal');
xlabel('Time'); ylabel('Frequency');
