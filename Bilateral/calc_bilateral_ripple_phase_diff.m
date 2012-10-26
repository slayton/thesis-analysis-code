function [results] = calc_bilateral_ripple_phase_diff(ripples)
 
    % Prepare the data for analysis
    nAnimal = numel(ripples);
    nRipple = sum( arrayfun(@(x) size(x.raw{1},1), ripples, 'UniformOutput', 1) );

    [phase1, phase2] = deal( zeros( nRipple,1 ) );
    
    curIdx = 1;
    for iAnimal = 1:nAnimal
     
        r = ripples(iAnimal);
        peakIdx = find(r.window==0) - 1; % correction for bad peak indexing!?!
        nRip = numel(r.peakIdx);
        
        h1 = hilbert(r.rip{1}')';
        h2 = hilbert(r.rip{3}')';

        % unwrap the phases so we can compute a clean difference in angles
        p1 = unwrap( angle(h1) );
        p2 = unwrap( angle(h2) );
        
        p1 = p1(:, peakIdx);
        p2 = p2(:, peakIdx);

        phase1(curIdx:(curIdx+nRip-1)) = p1;
        phase2(curIdx:(curIdx+nRip-1)) = p2;
        
        curIdx = curIdx + nRip;
        
        
    end
    
    dPhase = phase1 - phase2;
     
    % mod by 2pi to bring it with that valid range of [-pi pi]
    results.dPhase  = mod(dPhase, 2*pi)-pi;
    results.p1      = mod(phase1, 2*pi)-pi;
    results.p2      = mod(phase2, 2*pi)-pi;
       
end