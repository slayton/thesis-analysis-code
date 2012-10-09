function [indexes] = selectByTimes(times, tstart, tend)
% selectByTimes(times, tstart, tend)
% returns the index of values in the array times that are between tstart
% and tend.  If the value of tend or tstart is included in the array its
% index will also be returned

indexes = times>=tstart & times<=tend;
indexes = find(indexes);