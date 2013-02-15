
%% Load DATA
clearvars -except baseDir
[cl, data, ttList] = load_clusters_for_day(baseDir);
pos = load_exp_pos(baseDir, ep);

stats = computeClusterStats(baseDir);

[en, et] = load_epochs(baseDir);

input.description = baseDir;
input.ep = 'amprun';
input.et = et( strcmp(en, input.ep), :);

clAmp = data;

% filter the spikes for only spikes that were clustered
for iTT = 1:numel(cl)
    idx = false( size( data{iTT}, 1));
    for iCl = 1:max(cl{iTT})
        if stats(iTT).nSpike(iCl) > 100 && stats(iTT).lRatio(iCl) <= .05
            idx = idx | Cl == cl{iTT};
        end
    end
    clAmp{iTT} = clAmp{iTT}(idx,:);
end

clust = {};
% Group the spikes by clusters instead of by tetrode
for iTT = 1:numel(cl)
    
    fprintf('TT%d :', iTT)
    
    for iCl = 1:max(cl{iTT})
        if stats(iTT).nSpike(iCl) > 100 && stats(iTT).lRatio(iCl) <= .05
            fprintf('%d ', iCl)
            idx = iCl == cl{iTT};
            clust{end+1} = data{iTT}(idx,:);
        end
    end
    
    fprintf('\n');
end

input.data{1} = data;
input.data{2} = clAmp;
input.data{3} = clust;
input.data{4} = clust;

input.resp_col{1} = [1 2 3 4];
input.resp_col{2} = [1 2 3 4];
input.resp_col{3} = [1 2 3 4];
input.resp_col{4} = [];



%%
z = kde_decoder(stimTime, stimPos, spikeTime, spikePos, spikeAmp, ...
    'encoding_segments', runSegments, ...
    'stimulus_variable_type', 'linear', ...
    'stimulus_grid', {posGrid}, ...
    'distance', posDist,...
    'stimulus_kernel', 'gaussian', ...
    'stimulus_bandwidth', stimBandwidth, ...
    'response_variable_type', 'linear', ...
    'response_kernel', 'gaussian', ...
    'response_bandwidth', respBandwidth, ...
    'rate_offset', .0001);


% %% COMPUTE THE ESTIAMTE
% clear output;
% for i=1:numel(input.data)
%     tic;
%     disp(['Decoding: ', input.method{i}]);
%     [output.est{i} output.tbins output.pbins output.edges] =...
%         decode_amplitudes_par(input.data{i}, input.pos.lp', input.t_range, input.d_range,...
%         'resp_col', input.resp_col{i});    
%     output.elapsed_time(i) = toc;
%     toc;
% end


%% Compute Statistics
nboot = 0;
[output.stats.errors output.stats.me output.stats.me_dist] = calc_recon_errors(output.est, output.tbins, output.pbins, input.pos, 'n_boot', nboot);
[output.stats.mi output.stats.mi_var] = calc_recon_mi(output.est, output.tbins, output.pbins, input.pos, 'n_boot',nboot);


%% save the data

if saveData ==1
    
    curDir = pwd;
    
    cd ('/data/amplitude_decoding/revisions');
    filename = ['kKlust_vs_4_feature.', animal,'.',date, '.mat'];
    save(filename, 'input', 'output');
    
    cd(curDir);
    clear curDir;
end
