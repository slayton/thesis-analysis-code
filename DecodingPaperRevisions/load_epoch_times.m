function et = load_epochs_times(baseDir)


[en, et] = load_epochs(baseDir);
et = et( strcmp(en, 'amprun'), :);

end