function process_dataset_waveform_file(baseDir, minVel, minAmp)

if nargin<2 || isempty(minVel)
    minVel = 0;
elseif ~isscalar(minVel)
    error('MinVel must be a scalalr');
end

if nargin<3 || isempty(minAmp)
    minAmp = 75;
elseif ~isscalar(minAmp)
    error('MinVel must be a scalalr');
end


klustDir = fullfile(baseDir, 'kKlust');

if ~exist( fullfile(klustDir, 'dataset_ts.mat'), 'file');
    save_dataset_waveforms(baseDir);
else
    
    vars = {'ts', 'lp', 'lv', 'amp', 'wide', 'waveform', 'ttList'};
    for iVar = 1:numel(vars)
        fn =  sprintf('%s/dataset_%s.mat', klustDir, vars{iVar} );
        in = load( fn ); %#ok
        eval( sprintf('%s = in.%s;', vars{iVar}, vars{iVar} ));
    end
    
end

data = repmat({}, size(ts)); %#ok
pc = repmat({}, size(ts));

for i = 1:numel(ts)
    
    t = ts{i};
    a = amp{i}; %#ok
    w = wide{i}; %#ok
    wf = waveform{i}; %#ok
    p = lp{i}; %#ok
    v = lv{i}; %#ok
    
    
    
    if isempty(t) || isempty(a) || isempty(w) || isempty(wf) || size(wf,3) < 25
        
        data{i} = [];
        pc{i} = [];
        
    else
        pc{i} = calc_waveform_princom(wf); % compute PCA on all spikes not just clustered spikes

        
        nanIdx = isnan(p) | isnan(v);
        runIdx = abs(v) >= minVel;
        ampIdx = max(a,[],2) >= minAmp;
        
        idx = ~nanIdx & runIdx & ampIdx;
        
        a = a(idx,:);
        t = t(idx);
        p = p(idx);
        v = v(idx);
        w = w(idx);
        wf = wf(:,:, idx); %#ok<NASGU>
        
        data{i} = [a, t, p, v, w];
       
        pc{i} = pc{i}(idx,:);
        
    end
end

f1 = sprintf('%s/spike_params.mat', klustDir);
f2 = sprintf('%s/spike_params_pca.mat', klustDir);

fprintf('Saving %s\n', f1);
fprintf('Saving %s\n', f2);

save( f1, 'data');
save( f2, 'pc');

end