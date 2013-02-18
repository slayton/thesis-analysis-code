function [nClust, id] = load_cluster_file(clFile)


if exist(clFile, 'file')
    
    in = dlmread(clFile, '\n');

    nClust = in(1);
    id = in(2:end);
    
else
    
    nClust = 0;
    id = [];
    
end


end