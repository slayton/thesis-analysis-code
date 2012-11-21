function exp_save_eeg_mat(edir)
    
    fprintf('\nSaving eeg .mat file for:%s\n\n', edir);
    fileList = dir( fullfile(edir, '*.buf') );
    newFs = 1500;
    
    for i = 1:numel(fileList)
        inFile = fullfile(edir, fileList(i).name);
        outFile{i} = fullfile(edir, [fileList(i).name(1:end-4), '.', num2str(newFs), '.mat']);
        
        if ~exist(outFile{i}, 'file');
            fprintf('Debuffering %s...', inFile);
            debuffer_eeg_file(inFile, outFile{i}, 'Fs', newFs);
            fprintf(' DONE! Saved as:%s\n', outFile{i});
        end
    end
    
    
    clearvars -except outFile edir newFs;
        
    % Load the unbuffered data into memory
    fprintf('Loading the unbuffered data\n');
    for j = 1:numel(outFile)
        inFile = outFile{j};
        dataIn(j) = load( mwlopen( inFile ) );
    end  
    
    % get the epoch names and times
    [en et] = load_epochs(edir);
        
    for i = 1:numel(en)
        if ~any( strcmp( {'sleep1', 'run', 'sleep2', 'run1', 'run2', 'sleep3', 'sleep4'}, en{i}) )
            fprintf( 'Skipping epoch:%s\n', en{i} );
            continue;
        end
        
        doneFile = fullfile(edir, [en{i}, '.1500hz.eeg.mat']);
        if ~exist(doneFile, 'file')
            % Define the timestamp/sampling vector             
            ts = et(i,1): 1.000 / newFs : ( et(i,2) - (1.000 / newFs) );

            fprintf('Downsampling for epoch:%s ', en{i});
            % resample each channel at the specified times
            for j = 1:numel(outFile)
                for k = 1:8
                    chanStr = sprintf('channel%d', k);
                    data(j).(chanStr) = interp1( dataIn(j).timestamp, single( dataIn(j).(chanStr) ), ts );
                end
            end

            % Combine and SAVE!
            eeg = [data(1).channel1; data(1).channel2; data(1).channel3; data(1).channel4; ...
                data(1).channel5; data(1).channel6; data(1).channel7; data(1).channel8; ...
                data(2).channel1; data(2).channel2; data(2).channel3; data(2).channel4; ...
                data(2).channel5; data(2).channel6; data(2).channel7; data(2).channel8];


            save(doneFile, 'eeg', 'ts');

            fprintf(' %s SAVED!\t');
        else
            fprintf('EEG for %s already saved!\n', en{i});
        end
    end
    fprintf('\n');

end