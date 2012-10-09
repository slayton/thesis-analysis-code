function [field, fieldMin] = calculatePlaceField(spikePos, position, dt, useDirection, spikePosDir, posDir) 
%calculatePlaceField(spikePos, spikeTimes, deltaT, useDirection, spikePosDir, posDir)
%This code is incorrect and obselete please use calculate_tuning_curve
%instead
%
% Calculates place field of a cells using the positions of the animal and
% the times when spikes were recorded.
% 
% spikePos = vector containing locations of were a spike was recorded
% position = vector containing all the recorded positions of the animal
%   Assumed to be in PIXELS units
% dt = 1/(pos_sample_rate)
% useDirection is a boolean input:
%       0 - Ignore direction
%       1 - Include Direction
% spikePosDir is the vector of binarized direction for spikes 0 for inbond 1 for
% outbound (must be same length as spikePos)
% posDir is the vector of binarized direction for the position (must be
% same length as position)
%
% field is a vector containing the average firing rate of position
% fieldMin is the position that field(1) corresponds to
%
% Place fields are caluclated using the following formula:
% f(x) = S(x) / ( N(x) * dT) )      with:
% f(x) = ave firing rate at pos x
% S(x) = total number of spikes at pos x
% N(x) = Number of times animal was found at pos x
% dT = (position sample rate)^-1
%
% This code can be used to calculate other tuning curves as well, but the
% appropiate adjustments need to be made by the user 


posOccupancy = zeros(length(min(position):max(position)),1); %occupancy counter
posSpikesCount = zeros(length(min(position):max(position)),1); %spike counter

posOccupancy2 = zeros(length(min(position):max(position)),1);
posSpikesCount2 = zeros(length(min(position):max(position)),1);

posOffset = 1-min(position); % correct for negative position values
%disp(strcat('min:', int2str(min(spikePos)),' max:', int2str(max(position))));

position = position + posOffset;
spikePos = int16(spikePos) + posOffset;
%disp(strcat('Offset:', int2str(posOffset)));

for i=1:length(position)
    if useDirection  & posDir(i)
        posOccupancy2(position(i)) = posOccupancy2(position(i))+1;
    else
        posOccupancy(position(i)) = posOccupancy(position(i))+1;
    end;
end;% posOccupancy = N(x)

for i=1:length(spikePos)
    if  useDirection & spikePosDir(i) 
        posSpikesCount2(spikePos(i)) = posSpikesCount2(spikePos(i))+1;
    else
        posSpikesCount(spikePos(i)) = posSpikesCount(spikePos(i))+1;
    end;
end;% posSpikesCount = S(x)
field = posSpikesCount ./ (posOccupancy * dt);

field(isnan(field))=0;
field(isinf(field))=0;

field = smoothn(field, 3);

if useDirection
    field2 = posSpikesCount2 ./ (posOccupancy2 * dt);
    field2(isnan(field2))=0;
    field2(isinf(field2))=0;
    field2 = smoothn(field2, 3);
    field(:,2) = field2;
end;

fieldMin = posOffset - 1;


disp('This code is incorrect and obselete please use calculate_tuning_curve instead');