function p = dset_get_pos_file_path(animal, day)


if (day<10)
    filename = [animal, 'pos', '0', num2str(day), '.mat'];
else
    filename = [animal, 'pos', num2str(day), '.mat'];
end

p = fullfile(dset_get_base_dir(animal), filename);

%if the file doesn't exist try lower case
if ~exist(p, 'file')
    
    p = fullfile(dset_get_base_dir(animal), lower(filename));
    
    if ~exist(p, 'file')
        warning(['File does not exist:', p]);
        p = [];
    end

end