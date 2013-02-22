function cluster_feature_files(baseDir, prefix, nChan)

if ~ischar(baseDir) || ~exist(baseDir, 'dir')
    error('baseDir must be a string and valid directory');
end

if ~ischar(prefix) || ~any( strcmp( prefix, {'amp', 'pca'} ) )
    error('Prefix must be string containing either: amp or pca');
end

if ~isnumeric(nChan) || ~isscalar(nChan) || ~inrange(nChan, [1 4]);
    error('nChan must be a numeric scalar between 1 and 4');
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
