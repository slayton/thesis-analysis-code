function [partitions sis1 sis2] = evaluate_partitions(part_in, pos)

p_count = 0;
    for i=1:length(part_in)
        warning off;
        [cv1 cv2] = calculate_place_field(part_in(i).time, pos.linear_position, pos.timestamp, pos.linear_direction, 1/30);
        warning on;
        part_in(i).field1 = cv1;
        part_in(i).field2 = cv2; 
        %disp([i a1(i)  a2(i)])
        
        sis1 = spatialinfo(cv1);
        sis2 = spatialinfo(cv2);
        fis1 = fisherinfo(cv1);
        fis2 = fisherinfo(cv2);
        
        fs = 10; %minimum field size of 10
        si = .75; %minimum spatial information
        mr = 45; %maximum rate of 
        mp =  4; %minimum peak rate
        
        if (sum(cv1)>fs || sum(cv2)>fs)...  
                && (sis1>si || sis2>si) ... 
                && max(cv1)<mr && max(cv2)<mr ... %max rate can't be highter then 50
                && (max(cv1)>mp || max(cv2)>mp)   % cell must have a minimum of peak rate of 3hz
            p_count = p_count+1;
            partitions(p_count) = part_in(i);
            dir1(p_count,:) = cv1;
            dir2(p_count,:) = cv2;
            
        end
    end
   % v = 1:max([max(a1), max(a2)]);
   % figure; subplot(211); hist(a1,v); subplot(212); hist(a2,v) 
   
   sis1 = spatialinfo(dir1);
   sis2 = spatialinfo(dir2);
   disp(['Filtered down to:', num2str(p_count), ' partitions.']);
  
end