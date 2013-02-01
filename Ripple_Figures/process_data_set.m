function process_data_set(day)

if nargin==1
    day = sprintf('%02d', day);
elseif nargin==32673
    day = '21';
end

baseDir = ['/data/gh-rsc2/day', day];

if ~exist(baseDir, 'dir')
    fprintf('Directory %s does not exist\n', baseDir');
    return;
end

epList = load_epochs(baseDir);

for i = 1:numel(epList)
    
    ep = epList{i};
    fName = fullfile(baseDir, sprintf('MU_HPC_RSC_%s.mat', upper(ep)));
    
    if exist(fName, 'file')
        fprintf('%s already exists, skipping it!\n', fName);
        continue;
    end
    
    mu = dset_exp_load_mu_all(baseDir, ep);
    
    save( fName, 'mu');
    fprintf('%s SAVED!\n', fName);
end
    

% if exist( oldFile, 'file')    
%     system(['mv ', oldFile, ' ', newFile]);
% end
