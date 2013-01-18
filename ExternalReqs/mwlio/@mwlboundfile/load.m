function cb = load(bf, cid)
%LOAD load cluster boundaries
%
%  bounds=LOAD(f) load all cluster boundary data. The function returns
%  a structure array with the following fields:
%  nbounds - the number of boundaries for a given cluster
%  bounds - a structure array with boundary information
%  The length of the structure array is determined by the maximum cluster
%  number found in the file. Thus if the file contains boundary data for
%  clusters 1,2 and 5, then the returned structure array has five
%  elements. The third and fourth elements are empty structures.
%
%  A boundary information structure has the following fields:
%  projections - the IDs of the projections that this boundary was
%  defined in
%  projection_names - the names of the projections
%  vertices - a matrix of boundary vertices
%
%  bounds=LOAD(f, cluster) loads the boundary information for the
%  specified cluster only.
%
%  Example
%    f = mwlboundfile('test.dat');
%    b = load(f);
%

%  Copyright 2005-2008 Fabian Kloosterman

fid = fopen( fullfile(bf), 'r');

if fid == -1
    error('mwlboundfile:load:invalidFile', 'Cannot open file')
end

if nargin<2
    cid = -1;
end

%fseek to header offset
fseek(fid, get(bf, 'headersize'), -1);

cb = struct('nbounds', {}, 'bounds', {});

while ( ~feof(fid) )
    
    lin = fgetl(fid);
    
    if ~isempty(deblank(lin))
        
        cluster_id = str2num(lin); %#ok
        
        if length(cb)<1
            cb(cluster_id).bounds = struct('projections', {}, 'projection_names', {}, 'vertices', {});
        end
        if cluster_id>length(cb) || isempty(cb(cluster_id).nbounds)
            cb(cluster_id).nbounds = 1;
        else
            cb(cluster_id).nbounds = cb(cluster_id).nbounds + 1;
        end
        
        [cb(cluster_id).bounds(end+1).projections, np] = sscanf( fgetl(fid), '%d' );
        
        cb(cluster_id).bounds(end).projection_names = textscan(fid, '%s', np, 'Delimiter', ' ');
        
        ncoord = fscanf(fid, '%d', 1);
        
        cb(cluster_id).bounds(end).vertices = fscanf(fid, '%f', [2 ncoord])';
        
    end
    
end

if cid>0 && cid<=numel(cb)
  cb = cb(cid);
elseif cid>numel(cb)
  cb = struct('nbounds', {}, 'bounds', {});
end
    
