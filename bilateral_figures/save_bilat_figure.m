function save_bilat_figure(figName, fHandle, sup)

if nargin==2
    saveDir = '/data/bilateral/figures';
elseif nargin==3 && ~isempty(sup) && sup==1
    saveDir = '/data/bilateral/figures/sup';
end

figName = [figName,'-', datestr(now, 'yyyymmdd')];

saveFigure(fHandle, saveDir, figName, 'png', 'fig', 'svg');

end