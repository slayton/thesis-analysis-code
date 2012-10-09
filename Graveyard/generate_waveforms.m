function generate_waveforms(session_dir)

epochs = load_epochs(session_dir);
flds = mwlfield({'ch1', 'ch2', 'ch3', 'ch4'}, {'double', 'double', 'double', 'double'}, {32 32 32 32});

for i=1:length(epochs)
   epoch_dir = fullfile(session_dir, 'epochs', epochs{i}); 
   tt_dirs = get_dir_names(fullfile(epoch_dir, 't*'));
   
   for j=1:length(tt_dirs)
       cl_files = get_dir_names(fullfile(epoch_dir, tt_dirs{j}, 'cl*'));
       
       tt = mwlopen(fullfile(epoch_dir, tt_dirs{j}, [tt_dirs{j}, '.tt']));
       for h=1:length(cl_files)
           cl = mwlopen(fullfile(epoch_dir, tt_dirs{j}, cl_files{h}));
           id = load(cl);
           id = id.id;
           waves = load(tt, 'waveform', id);   
           wave_avg = mean(waves.waveform,3);
           data = {wave_avg(1,:), wave_avg(2,:), wave_avg(3,:), wave_avg(4,:)};
           
           wave_file = fullfile(epoch_dir, tt_dirs{j}, ['waveform-', num2str(h)]);
           head = header('Program', mfilename, 'Date', [datestr(now, 'ddd ') datestr(now, 'mmm dd HH:MM:SS yyyy')]);
           nf = mwlcreate(wave_file, 'feature', 'Fields', flds, 'Header', head, 'Data', data, 'Mode', 'overwrite');
           disp([wave_file, ' saved!']);
       end
   end   
end
    

%{
 %reate new file header
  
   

    wave_new = wave_temp;
    

    h = header('Program', mfilename, ...
                   'Date', [datestr(now, 'ddd ') datestr(now, 'mmm dd HH:MM:SS yyyy')]);
        
    %create new file
    dest_file= '/home/slayton/testfile';
    nf = mwlcreate(dest_file, 'feature', 'Fields', flds, 'Header', h,...
        'Data', {wave_new(1,:), wave_new(2,:), wave_new(3,:), wave_new(4,:)}, ...
        'Mode', 'overwrite');
    nf = closeHeader(nf);
%}