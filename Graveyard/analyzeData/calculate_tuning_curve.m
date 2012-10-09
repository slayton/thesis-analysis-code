function curve = calculate_tuning_curve(spike_pos, position, varargin) 
%CALCULATE_TUNING_CURVE
%
%   curve = CALCULATE_TUNING_CURVE(spikes, behavior, delta_t)
%
%   curve = CALCULATE_TUNING_CURVE(spikes, behavior, delta_t, stdev) 
%
%   SPIKE_POS is a vector containing the value of a user decided property when
%   a spike was recorded. FOR EXAMPLE: SPIKE_POS could be the POSITION of
%   the animal when a cell fired, it could also be a vector of HEAD
%   DIRECTIONS
%
%   BEHAVIOR is a vector containing all samples taken over the course of
%   the experiment. FOR EXAMPLE: a vector containing all POSITIONS of the
%   animal or all HEAD DIRECTIONS.  
%
%   DELTA_T, is a scalar representing the time in seconds between samples
%   of the BEHAVIOR vector. FOR EXAMPLE, if behavior is a vector of
%   positions then DELTA_T equals 1/Fs where Fs is the rate of sampling for
%   animal position.
%
%   STDEV is a used to create a gaussian kernel with a standard deviation
%   of STDEV
%
%
%   CURVE is calculated according to the following equation:
%
%   f(x) = S(x)/(N(x) * delta_t)
%   f(x) is the rate at position x
%   S(x) is the number of spikes observed at position x
%   N(x) is the time spent at position x
%   delta_t is 1/Fs or the time spent at a location per sample

if size(varargin,2)<1
    disp('delta_t not specified');
    disp('cannot compute rates');
else
    pos_min=min(position);
    pos_max=max(position);
    behavior_occupancy = hist(position, pos_min:1:pos_max);
    spikes_occupancy = hist(spike_pos, pos_min:1:pos_max);

    if size(varargin,2)>1    
        std_dev = varargin{2};
        behavior_occupancy = smoothn(behavior_occupancy, std_dev);
        spikes_occupancy = smoothn(spikes_occupancy, std_dev);
    end

    delta_t = varargin{1};
    curve = spikes_occupancy ./(behavior_occupancy * delta_t);

end
end


    
    