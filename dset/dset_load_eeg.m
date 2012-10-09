function [eeg, ref, metaAll] = dset_load_eeg(animal, day, epoch, electrode)
% DSET_LOAD_EEG - loads the eeg records from disk
eeg = [];
% return;

filepath = dset_get_eeg_file_path(animal, day, epoch, electrode);
metapath = dset_get_tetinfo_file_path(animal);

% for i = 1:numel(filepaths)
metaAll = load(metapath);

for i = 1:numel(filepath)
    
    if ~exist(filepath{i},'file')
        warning(['File: ', filepath{i}, ' does not exist! Cannot load eeg']);
        continue;
    end
    
    disp(['Loading eeg from files:', filepath{i}]);

    data = load(filepath{i});
    data = data.eeg{day}{epoch}{electrode(i)};
    meta = metaAll.tetinfo{day}{epoch}{electrode(i)};

    eeg(i).data = data.data;
    eeg(i).starttime = data.starttime;
    eeg(i).fs = data.samprate;
    
    if isfield(meta, 'hemisphere')
        eeg(i).hemisphere = meta.hemisphere;
    else
        eeg(i).hemisphere = 'unknown';
    end
    
    if isfield(meta, 'area')
        eeg(i).area = meta.area;
    else
        eeg(i).area = 'unkown';
    end
    eeg(i).tet = electrode(i);
end


if (isempty(eeg))
    return
end

refIdx = strcmp( {eeg.area}, 'Reference');
ref = eeg(refIdx);
ref = dset_resample_reference(eeg(1), ref);


lIdx = strcmp({eeg.hemisphere}, 'left');
rIdx = strcmp({eeg.hemisphere}, 'right');

ca1Idx = strcmp({eeg.area}, 'CA1');
ca3Idx = strcmp({eeg.area}, 'CA3');

idx = (lIdx | rIdx) & (ca1Idx | ca3Idx) ;

eeg = eeg(idx);



end
