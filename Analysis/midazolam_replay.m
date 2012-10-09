%% Midazolam Replay??!?!?!


clear; clc;

mid.ses = '/home/slayton/data/disk1/fab/fk18/day09';
mid.ep = 'midazolam';

mid.pos = load_position(ses, ep);
mid.mua = load_multiunit(ses, ep);
mid.clusters = evaluate_place_cells(load_clusters(ses, ep), mid.pos);
mid.partitions = evaluate_partitions(load_partitions(ses, ep),mid.pos);

cells2use = mid.clusters;
reconstruction_browser(cells2use, mid.pos, mid.mua);


run1.ses = '/home/slayton/data/disk1/fab/fk18/day07';
run1.ep = 'run1';

run1.pos = load_position(run1.ses, run1.ep);
run1.mua = load_multiunit(run1.ses, run1.ep);
run1.clusters = evaluate_place_cells(load_clusters(ses,ep), run1.pos);
run1.partitions = evaluate_partitions(load_partitions(ses, ep), run1.pos);
