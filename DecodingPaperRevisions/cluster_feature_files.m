function cluster_feature_files(baseDir, prefix, nChan)

if nargin <2 || isempty(prefix);
    prefix = 'amp';
end

if nargin < 3 || isempty(nChan)
    nChan = 4;
end

if ~ischar(prefix) || ~any( strcmp( prefix, {'amp', 'pca'} ) )
    error('Prefix must be string containing either: amp or pca');
end


klustDir = fullfile(baseDir, 'kKlust');
if ~exist(klustDir, 'dir');
    write_feature_files(baseDir);
end

curDir = pwd;
cd(klustDir);

in = load( sprintf('%s/dataset_%dch.mat', klustDir, nChan), 'ttList');
ttList = in.ttList;

nTT = numel(ttList);

fprintf('Clustering...\n');

for iTetrode = 1:nTT
 
    featFile = sprintf('%s/%s.%dch.fet.%d', klustDir, prefix, nChan, iTetrode);
    
    if ~exist( featFile, 'file');
        fprintf('%s does not exist, skipping it\n', featFile);
        continue;
    end
    
    fprintf('\t%s ', featFile);
    
    cmd = sprintf('~/src/clustering/kk2.0/KlustaKwik %s.%dch %d -Screen 0 -Log 0',prefix, nChan, iTetrode );
    [s, w] =  unix(cmd);
    
    fprintf('\n');

    
    clFile = sprintf('%s/%s.%dch.clu.%d', klustDir, prefix, nChan, iTetrode);
    
    if ~exist(clFile, 'file');
%         fprintf('%s not written, creating dummy file\n', clFile);
         [s, w] = unix( sprintf( 'touch %s', clFile) );
    end
    
end  

cd(curDir)

fprintf('Done!\n');
