function [amp] = load_dataset_features(baseDir)

if nargin==1
    plot = 0;
end
klustDir = fullfile(baseDir, 'kKlust');

if ~exist(klustDir, 'dir')
    error('%s does not exist', klustDir);
end

in = load( fullfile(klustDir, 'ttMap.mat') );
nTT = numel(in.ttList);

in = load (fullfile(klustDir, 'spikes.mat') );
spikes = in.data;


amp = repmat({}, nTT, 1);
for i = 1:nTT
    
    fFile = sprintf('%s/tt.fet.%d', klustDir, i);
    feat = load_feature_file(fFile);
    
    if any(isnan(feat(:))) || numel(feat) < 8
        amp{i} = [];
        continue;
    end
    
    size(feat)
    size(spikes{i}(:,5:8))
    amp{i} = [feat, spikes{i}(:, 5:8)];
    
end

end