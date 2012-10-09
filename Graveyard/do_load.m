function exp = do_load(session_dir, epochs, varargin)
% exp = do_load(session_dir, epochs)
% exp = do_load( ... , force_user_input)
        
    switch numel(varargin)
        case 0
            force_evaluation = 0;
        case 1
            force_evaluation = varargin{1};
     end

    orig_data =1;
    % Load Experiment
    exp = load_experiment(session_dir, epochs);
    epochs = exp.epochs;
    
    % Get Valid EEG channels
    if ~exist(fullfile(session_dir,'valid_eeg_chans.mat'),'file') || force_evaluation
        valid_eeg_chans = evaluate_eeg(exp, orig_data, force_evaluation);
    else
        d = load(fullfile(session_dir,'valid_eeg_chans.mat' ));
        valid_eeg_chans = d.valid_chan;
    end
       
    
    % Get Valid Clusters
    for e = epochs
        e = e{:};
        if ~exist(fullfile(session_dir,'epochs', e, 'gc.mat'),'file') || force_evaluation
            gc = evaluate_place_cells(exp, orig_data, force_evaluation);
            break
        else
            d = load(fullfile(session_dir,'epochs', e, 'gc.mat'));
            gc.(e) = d.gc;
        end
    end
    
    % Filter down to valid channels 
    for e = epochs
        e = e{:};
        exp.(e).clusters = exp.(e).clusters(gc.(e));
        exp.(e).clusters = exp.(e).clusters(sort_clusters(exp.(e).clusters, 1));
        exp.(e).eeg = exp.(e).eeg(valid_eeg_chans);
    end
    
end

