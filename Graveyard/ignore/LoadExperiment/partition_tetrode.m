function clp =  partition_tetrode(session_dir, epoch, tetrode_id)

    tetname = tetrode_id;
    parm_file = fullfile(session_dir, 'epochs', epoch, tetrode_id, [tetrode_id, '.pxyabw']);
    tt_file = fullfile(session_dir, 'epochs', epoch, tetrode_id, [tetrode_id, '.tt']);
    

    
    [n t] = load_epochs(session_dir); 
    
    time_win = t(strcmp(n, epoch),:);
    gains = load_gains(tt_file);
    thold = 100;
    
    cl = parm2cl('parmfile', parm_file, 'gain', gains, 'timewin', time_win,...
        'trodeno', tetrode_id, 'uvthresh', thold);
    
    
    r_spilts = [0 100];  %#ok Default Value 
    ang_splits = [0 33 67 100];
    
    clp = clpart('cl', cl, 'uvthresh', thold,'ang_splits', ang_splits, ...
                'keepfields', {'time'});
    
            
end
