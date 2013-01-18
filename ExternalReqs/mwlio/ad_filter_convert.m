function [lp, hp] = ad_filter_convert(FilterSetting)
%AD_FILTER_CONVERT convert ad filter setting
%
%  [low,high]=AD_FILTER_CONVERT(f) returns the low cut-off and high
%  cut-off frequencies encoded in the value f. This value is typically
%  retrieved from mwl file type headers and specifies the filter settings
%  of a Neuralynx amplifier.
%
%  Example
%    filter_stting = 136;
%    [low, high] = ad_filter_convert( filter_setting );
%    %returns low = 300, high = 6000
%

%  Copyright 2005-2008 Fabian Kloosterman


lp = -1;
hp = -1;

BIT0 = 1;
BIT1 = 2;
BIT2 = 4;
BIT3 = 8;
BIT4 = 16;
BIT5 = 32;
BIT6 = 64;
BIT7 = 128;
BIT8 = 256;
BIT9 = 512;

HDAMP_LOWCUT_TENTHHZ = 0; %#ok
HDAMP_LOWCUT_1HZ = BIT0;
HDAMP_LOWCUT_10HZ = BIT1;
HDAMP_LOWCUT_100HZ = BIT2;
HDAMP_LOWCUT_300HZ = BIT3;
HDAMP_LOWCUT_600HZ = BIT4;
HDAMP_LOWCUT_900HZ = bitor(BIT3,BIT4);

HDAMP_HICUT_50HZ = 0;
HDAMP_HICUT_100HZ = BIT5;   % 120 HZ ACTUALLY
HDAMP_HICUT_200HZ = BIT8;
HDAMP_HICUT_250HZ = BIT9;
HDAMP_HICUT_275HZ = bitor(BIT5,BIT8);
HDAMP_HICUT_325HZ = bitor(BIT5,BIT9);
HDAMP_HICUT_400HZ = bitor(BIT8,BIT9);
HDAMP_HICUT_475HZ = bitor(BIT5, bitor(BIT8,BIT9));
HDAMP_HICUT_3KHZ = BIT6;
HDAMP_HICUT_6KHZ = BIT7;
HDAMP_HICUT_9KHZ = bitor(BIT6,BIT7);

% First get the low cutoff

%if ( bitand(FilterSetting , (BIT0 | BIT1 | BIT2 | BIT3 | BIT4)) == 0 )	  % 0.1 Hz
if ( bitand(FilterSetting , 15) == 0 )	  % 0.1 Hz
    lp = 0.1;
end
if bitand(FilterSetting , HDAMP_LOWCUT_1HZ)				  % 1 HZ
    lp = 1;
end
if bitand(FilterSetting , HDAMP_LOWCUT_10HZ)				  % 10 Hz
    lp = 10;
end
if bitand(FilterSetting , HDAMP_LOWCUT_100HZ)				  % 100 Hz
    lp = 100;
end
if (bitand(FilterSetting , HDAMP_LOWCUT_900HZ) == HDAMP_LOWCUT_300HZ)	  % 300Hz
    lp = 300;
end
if (bitand(FilterSetting , HDAMP_LOWCUT_900HZ) == HDAMP_LOWCUT_600HZ)	  % 600Hz
    lp = 600;
end
if (bitand(FilterSetting , HDAMP_LOWCUT_900HZ) == HDAMP_LOWCUT_900HZ) 	  % 900 Hz
    lp = 900;
end

% and now get the high cutoff

if (bitand(FilterSetting , bitor(HDAMP_HICUT_475HZ , HDAMP_HICUT_9KHZ)) == HDAMP_HICUT_50HZ )      % 50 Hz
    hp = 50;
end
if (bitand(FilterSetting , bitor(HDAMP_HICUT_475HZ , HDAMP_HICUT_9KHZ)) == HDAMP_HICUT_100HZ  )    % 100 Hz
    hp = 100;
end
if (bitand(FilterSetting , bitor(HDAMP_HICUT_475HZ , HDAMP_HICUT_9KHZ)) == HDAMP_HICUT_200HZ  )    % 200 Hz
    hp = 200;
end
if (bitand(FilterSetting , bitor(HDAMP_HICUT_475HZ , HDAMP_HICUT_9KHZ)) == HDAMP_HICUT_250HZ  )    % 250 Hz
    hp = 250;
end
if (bitand(FilterSetting , bitor(HDAMP_HICUT_475HZ , HDAMP_HICUT_9KHZ)) == HDAMP_HICUT_275HZ  )    % 275 Hz
    hp = 275;
end
if (bitand(FilterSetting , bitor(HDAMP_HICUT_475HZ , HDAMP_HICUT_9KHZ)) == HDAMP_HICUT_325HZ  )    % 325 Hz
    hp = 325;
end
if (bitand(FilterSetting , bitor(HDAMP_HICUT_475HZ , HDAMP_HICUT_9KHZ)) == HDAMP_HICUT_400HZ  )    % 400 Hz
    hp = 400;
end
if (bitand(FilterSetting , bitor(HDAMP_HICUT_475HZ , HDAMP_HICUT_9KHZ)) == HDAMP_HICUT_475HZ  )    % 475 Hz
    hp = 475;
end
if (bitand(FilterSetting , HDAMP_HICUT_9KHZ) == HDAMP_HICUT_3KHZ )                            % 3000 Hz
    hp = 3000;
end
if (bitand(FilterSetting , HDAMP_HICUT_9KHZ) == HDAMP_HICUT_6KHZ )                            % 6000 Hz
    hp = 6000;
end
if (bitand(FilterSetting , HDAMP_HICUT_9KHZ) == HDAMP_HICUT_9KHZ )                            % 9000 Hz
    hp = 9000;
end
