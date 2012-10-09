function [data times] = buffer2vector(buffs, tstamp)
%   BUFFER2VECTOR(buffers, timestamps)
%
%   buffer2vector takes in two inputs: buffers and timestamps on those
%   buffers. 
%   BUFFS are NxMxP matrixs with N channels, M samples, and P buffers
%
%   TSTAMP are the timestamps of the 1st sample of a each buffer in BUFFS
%   
%   Two vectors are returned, data and times
%   DATA is Nx(M*P) with N channels and M*P samples
%   times is a 1x(M*P) vector with the estimated timestamp of each sample
%   in data
%
%   Stuart Layton, 2009


    data = reshape(buffs, size(buffs, 1), size(buffs,2)*size(buffs,3));
    tstart = double(tstamp(1));
    dt = double(mean(diff(tstamp)))/size(buffs,2);
    tend = double(tstamp(end)) + dt*size(buffs,2);
    times = tstart:dt:tend-dt;
end