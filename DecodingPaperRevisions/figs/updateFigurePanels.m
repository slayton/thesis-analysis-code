clear;
load decodeData.mat;
outDir = '/data/amplitude_decoding/NEW_FIGURES/';

% IN = in;\\
% P = p;

%%
sumError = [];
nSpike = [];
nTT = [];
nUnit = [];
for i = 1:numel(e)
    
    sumError = [ sumError; e{i}.summary_error];
    nSpike = [nSpike; in{i}.nSpike(1:2)]; 
    nTT(i) = sum( ~cellfun(@isempty, in{i}.data{1}));
    nUnit(i) = numel( in{i}.data{5});
end


%% Table 1
rName = {'SL13', 'SLD14', 'SLD15', 'SLD16', 'R1D1', 'R1D2', 'R2D1', 'R2D2', 'ESM11', 'ESM2', 'SAT2', 'FK11'};
cName = {'#TT w/ Spk', '#Spike','#Spike(sorted)', '%Sorted', 'N Unit'};
tbl = [nTT', nSpike(:,1), nSpike(:,2), nSpike(:,2)./nSpike(:,1), nUnit'];
writeTable(cName, rName, tbl,  fullfile(outDir, 'table1.csv'));


%% Figure 2-C

E = e{2};

[f1,x1] = ecdf(E(1).estimation_error);
[f2,x2] = ecdf(E(5).estimation_error);

line(x1,f1,'color', 'r');
line(x2,f2,'color', 'k');

figure;
axes;

i = E(1).confusion{1};
i = normalize(i);
i = repmat(i,[1,1,3]);
i = 1-i;
imagesc(0:.1:3.1, 0:.1:3.1,  i);
set(gca,'YDir', 'normal');
xlabel('True Position(m)');
ylabel('Estimated Position(m)');

imwrite(i, fullfile(outDir, 'Fig2C_confmat.png'), 'png');
plot2svg(fullfile(outDir, 'Fig2C.svg'), gcf);

%% Figure 5-A
cols = [2 1 4 5];

figure;
axes('FontSize', 14);

boxplot(sumError(:, cols))
set(gca,'XTick', [1 2 3 4], 'XTickLabel', {'Feat-Sort', 'Feat-All', 'Iden-All', 'Iden-Sort'});
ylabel('Median Error(m)');

plot2svg(fullfile(outDir, 'Fig5A.svg'), gcf);

%% Figure 5-B










