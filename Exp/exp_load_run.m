function e = exp_load_run(edir)

e = exp_load(edir, 'epochs', 'run', 'data_types', {'pos', 'clusters'});
e = process_loaded_exp2(e, [1 2 4 7]);
end