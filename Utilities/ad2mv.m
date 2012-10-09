function mv = ad2mv(signal, gain)
%   nv = AD2MV(signal, gains)
%   Converts from AD units to millivolts.
%   signal and gains must be the same size
    
    % correct for 0 gains
    is_zero = (gain==0);
    signal(is_zero)=0;
    gain(is_zero)=1;
    
    
    mv = double(signal)./4096 .* 10 .* 1e6;
    mv = bsxfun(@rdivide, mv, gain);
    
end
