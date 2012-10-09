function exp = process_experiment(exp, varargin)
%PREPROCESS_EXPERIMENT takes in an sl_experiment struct and process it. The
%different processes it performs are: 
% calc_tc       -Calculates tuning curves
% calc_mub      -Calculates multi-unit burst
% calc_rip_burst-calculates burst in the ripple band
% filt_clusters -Removes clusters that have been hand selected by user <=DEPRECATED
% filt_eeg      -Removes eeg channels that have been hand selected by user <= DEPRECATED
% sort_clusters -Sorts clusters according to the peak firing rate location
% cluster_stats -Calculates various statistics for each clustered cell
%
% exp=preprocess_experiment(exp) perofmes all available operations on the
% experiment structures
%
% exp=preprocess_experiment(..., param, val, ...)  available param values
% pairs are: 
%   operations, {list of operations}
%   force_eval, 0 or 1 
%   eeg_channel, index of the eeg struct to use for the rip_burst trigger
%
% Valid Operations: calc_tc, calc_mub, calc_rip_burst, filt_eeg,
%                   sort_clustres, filt_clusters

warning('This is a depricated function, use process_loaded_exp instead');

args.operations = {...
    'calc_tc', 'calc_mub','calc_rip_burst', 'filt_clusters',...
    'filt_eeg', 'sort_clusters', 'cluster_stats'
    };
args.force_eval = 0;
args.eeg_channel = 1;
args.epochs = fields(exp);

args = parseArgs(varargin, args);

for e = args.epochs
    e = e{:};

    
%% Remove invalid EEG traces
    if ismember('filt_eeg', args.operations);
        warning('This function is deprecrated and does nothing.');
        
        %{
        if isfield(exp.(e), 'eeg')
            disp([e, ': removing invalid eeg channels']);
            if ~exist(fullfile(exp.session_dir,'valid_eeg_chans.mat'),'file') || args.force_eval
                valid_eeg_chans = evaluate_eeg(exp, 1, args.force_eval);
                waitfor(gcf);
            else
                d = load(fullfile(exp.session_dir,'valid_eeg_chans.mat' ));
                valid_eeg_chans = d.valid_chan;
            end
            
            exp.(e).eeg = exp.(e).eeg(valid_eeg_chans); 
        else
            warning('structure does not have a eeg field, which is required to filter eeg channels');
        end
        %}
    end
   
    
%% Compute place fields
    if ismember('calc_tc', args.operations);
        if isfield(exp.(e),'position') && isfield(exp.(e),'clusters')
            disp([e, ': computing place fields']);

            [pos_bin_width smooth_width, pos_samp_freq] = deal(.10, .10, 30);

            cl = exp.(e).clusters;
            for i=1:length(cl)
                [cl(i).tc1 cl(i).tc2] =...
                    calculate_place_field(cl(i).time, exp.(e).position, 1/pos_samp_freq, ...
                    pos_bin_width, smooth_width);
                cl(i).tc_bw = pos_bin_width;
                cl = orderfields(cl);
            end
            exp.(e).clusters = cl;
        else
            warning('structure does not have a position or clusters field, both are required to calcualte tc');
        end
        
            
    end
    
%% Remove invalid clusters
    if ismember('filt_clusters', args.operations);
        warning('This function will soon be deprecated, please stop using it');
        if isfield(exp.(e), 'clusters')
            disp([e, ': removing bad clusters']);

            if ~exist(fullfile(exp.session_dir, 'epochs', e, 'gc.mat'), 'file') || args.force_eval
                gc = evaluate_place_cells(exp, 1, args.force_eval);
            else
                d = load(fullfile(exp.session_dir, 'epochs', e, 'gc.mat'));
                gc = d.gc;
            end
            if isstruct(gc)
                exp.(e).clusters = exp.(e).clusters(gc.(e));
                
            else
                exp.(e).clusters = exp.(e).clusters(gc);
            end
        else
            warning('structure does not have a clusters field, which is required to filter clusters');
        end
    end

    
%% Sorting placefields
    if ismember('sort_clusters', args.operations)
        if isfield(exp.(e), 'clusters')
            disp([e, ': sorting clusters']);
            exp.(e).clusters = exp.(e).clusters(sort_clusters(exp.(e).clusters, 1));
        else
            warning('structure does not have clusters field, which is required to sort clusters');
        end
    end

%% Compute MUB Bursts
    if ismember('calc_mub', args.operations);
        if isfield(exp.(e),'position') && isfield(exp.(e),'multiunit')
               disp([e, ': calculating multi-unit bursts']);
               [bt lt ht] = find_mu_burst(  exp.(e).multiunit.rate, ...
                                            exp.(e).multiunit.timestamps, ...
                                            exp.(e).position);
               mu = exp.(e).multiunit;
               mu.burst_times = bt;
               mu.low_threshold = lt;
               mu.high_threshold = ht;
               mu = orderfields(mu);

               exp.(e).multiunit = mu;          
        else
            warning('structure does not have a multiunit field, which is required to calculate mub');
        end
    end

%% Calculate Ripple Bursts 
    if ismember('calc_rip_burst', args.operations)
        if isfield(exp.(e), 'eeg')
            
            disp([e, ': calculating ripple bursts']);
            
            [exp.(e).rip_burst.windows exp.(e).rip_burst.params maxes] = ...
                find_rip_burst( exp.(e).eeg(args.eeg_channel).data,...
                                exp.(e).eeg_ts, ...
                                exp.(e).eeg(args.eeg_channel).fs);
             exp.(e).rip_burst.hil_max = maxes;
             exp.(e).rip_burst.trig_channel = args.eeg_channel;           
             
        else
           warning('structure does not have eeg field, which is required to calculate ripple bursts');
        end
    end
%% Calculate Cluster Statistics
    if ismember('cluster_stats', args.operations)
        if isfield(exp.(e), {'clusters', 'position'} )
            exp.(e).clusters = calc_cluster_stats(exp,e);
        else
            warning('Required data missing, unable to calculate cluster_stats');
        end
        
    end
    
end