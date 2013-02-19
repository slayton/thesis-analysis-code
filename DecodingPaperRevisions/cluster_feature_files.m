function cluster_feature_files(baseDir, prefix)

if nargin == 1 || isempty(prefix);
    prefix = 'tt';
end

if ~ischar(prefix)
    error('Prefix must be either: tt or pca');
end


klustDir = fullfile(baseDir, 'kKlust');
if ~exist(klustDir, 'dir');
    write_feature_files(baseDir);
end

curDir = pwd;
cd(klustDir);

in = load( fullfile(klustDir, 'dataset_ttList.mat'));
ttList = in.ttList;

nTT = numel(ttList);

fprintf('Clustering...\n');


for iTetrode = 1:nTT
 
    featFile = sprintf('%s/%s.fet.%d', klustDir, prefix, iTetrode);
    
    if ~exist( featFile, 'file');
        fprintf('%s does not exist, skipping it\n', featFile);
        continue;
    end
    
    fprintf('\t%s ', featFile);
    
    cmd = sprintf('~/src/clustering/kk2.0/KlustaKwik %s %d -Screen 0 -Log 0',prefix, iTetrode );
    [s, w] =  unix(cmd);
    
    fprintf('\n');

    clFile = sprintf('%s/%s.clu.%d', klustDir, prefix, iTetrode);
    
    if ~exist(clFile, 'file');
        fprintf('%s not written, creating dummy file\n');
        [s, w] = unix( sprintf( 'touch %s', clFile) );
    end
    
end  

cd(curDir)

fprintf('Done!\n');
