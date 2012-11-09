function save_bilat_figure(figName, fHandle, sup)

figName(1) = upper(figName(1));
if nargin==2
    saveDir = '/data/bilateral/figures';
elseif nargin==3 && ~isempty(sup) && sup==1
    saveDir = '/data/bilateral/figures/sup';
end

oldDir = fullfile(saveDir, 'old_figures');
if ~exist(oldDir, 'dir')
    mkdir(oldDir);
end
cmd = ['mv ', fullfile(saveDir,[figName, '*']), ' ', oldDir];
system(cmd);

figName = [figName,'__', datestr(now, 'yyyymmdd'),'_'];

set(gcf,'InvertHardcopy', 'off');

saveFigure(fHandle, saveDir, figName, 'png', 'fig', 'svg');

end