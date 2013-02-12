function [nClust id] = loadClusterIdentities(clFile)


in = dlmread(clFile, '\n');

nClust = in(1);
id = in(2:end);


end