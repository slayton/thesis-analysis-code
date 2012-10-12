function [stats, replay] = dset_calc_unilateral_replay_stats(d)

lIdx = strcmp({d.clusters.hemisphere}, 'left');
rIdx = strcmp({d.clusters.hemisphere}, 'right');
smoothPdf = 1;

[stats.L, replay.L ] = dset_calc_replay_stats(d, lIdx, [],[],smoothPdf);
[stats.R, replay.R ] = dset_calc_replay_stats(d, rIdx, [],[],smoothPdf);

end
