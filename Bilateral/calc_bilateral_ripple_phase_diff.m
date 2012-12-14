function [results] = calc_bilateral_ripple_phase_diff(ripples)
 
    % Prepare the data for analysis
    nAnimal = numel(ripples);
    nRipple = sum( arrayfun(@(x) size(x.raw{1},1), ripples, 'UniformOutput', 1) );

    phase = zeros( nRipple,3 );
    
    curIdx = 1;
    for iAnimal = 1:nAnimal
     
        r = ripples(iAnimal);
        peakIdx = find(r.window==0) - 1; % correction for bad peak indexing!?!
        nRip = numel(r.peakIdx);
     
        for i = 1:numel(r.rip)
            if isempty(r.rip{i})
                continue;
            end
            
            hil = hilbert(r.rip{i}')';
            
%             h3 = hilbert(r.rip{3}')';

        % unwrap the phases so we can compute a clean difference in angles
            phs = unwrap( angle(hil) );
%         p3 = unwrap( angle(h3) );
        
            phs = phs(:, peakIdx);
     
    
            phase(curIdx:(curIdx+nRip-1), i) = phs;
%         phase3(curIdx:(curIdx+nRip-1)) = p3;
        
        
        end
        curIdx = curIdx + nRip;
        
    end
    
    dPhase = phase(:,1) - phase(:,3);
    dPhaseIpsi = phase(:,1) - phase(:,2);
    dPhaseCont = dPhase;
     
    % mod by 2pi to bring it with that valid range of [-pi pi]
    %results.dPhase  = mod(dPhase, 2*pi)-pi;
    results.dPhaseIpsi = dPhaseIpsi;
    results.dPhaseCont = dPhaseCont;
    results.phase   =  phase;
    
       
end