function [vel times] = calculateVelocity(pos)
    
    range = max(pos) - min(pos);
    p1 = [pos(1) pos];
    p2 = [pos pos(end)];
    t1 = [ times];
    t2 = [times(2:end) times(end)];
    size(t1)
    size(t2)
    dT = 1/30;
    
    dP = p2-p1;
    dP = dP(1:(length(dP)-1));
    goodDP = abs(dP) < 15;
    dP = dP(goodDP);
    times = times(goodDP);
    
    vel = double(dP)/double(dT);




%range = max(pos) - min(pos);
%for sample=1:length(pos)
%   if (mod(sample, 1000) == 0) disp(sample); end;
%    if (sample<length(pos)-1)
%        val1 = pos(sample+1) - min(pos);
%        val2 = pos(sample) - min(pos);
%        vel(sample) = double( myMinus(val1, val2, range)) / double( times(sample+1) - times(sample) );
%    else
%        vel(sample) = vel(sample-1);
%    end
%end

