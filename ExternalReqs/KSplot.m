function getKSPlot(KSStat, varargin)
%function getKSPlot(KSStat, options)
%
% Takes array of scaled ISI distribution and compares to uniform
% distribution
%
% Options are
% 'confint', n		where n is 95 or 99
% 'color', 0 or 1	for color or black and white

confint = 95;
color = 1;
if (~isempty(varargin))
    assign(varargin{:});
end


% Eliminate zero entries and sort
% find the entries that are negative but > -1 and set to zero
KSStat(find((KSStat < 0) & (KSStat > -1))) = 0;
KSPos = KSStat(find(KSStat >= 0));
KSSorted = sort( KSPos );
N = length( KSSorted);


%95 interval = 1.36 ; 99% = 1.63
if (confint == 95)
    KSdist = 1.36;
elseif (confint == 99)
    KSdist = 1.63;
else
    error('Invalid confidence bound');
end

if (color)
    % Find KS statistic in uniform domain
    plot( KSSorted, ([1:N]-.5)/N, 'b', 'LineWidth', 2);  
    hold on
    plot(0:.01:1,0:.01:1, 'g', 'LineWidth', 2); 
    plot(0:.01:1, [0:.01:1]+KSdist/sqrt(N), 'r', 0:.01:1,[0:.01:1]-KSdist/sqrt(N), 'r' ); 
else
    plot( KSSorted, ([1:N]-.5)/N, 'k', 'LineWidth', 2.0);  
    hold on
    h = plot(0:.01:1,0:.01:1, 'LineWidth', 1); 
    set(h, 'Color', [.4 .4 .4]);
    h = plot(0:.01:1, [0:.01:1]+KSdist/sqrt(N), '--', 0:.01:1,[0:.01:1]-KSdist/sqrt(N), '--' ); 
    set(h(1), 'Color', [.4 .4 .4]);
    set(h(2), 'Color', [.4 .4 .4]);
end


axis( [0 1 0 1] );

% Or look at the KS plot in the exponential domain instead
%plot( -log(1-KSSorted),  ([1:N]-.5)/N, 'b', -log(1-[0:.001:.999]), ...
%      0:.001:.999, 'g', -log(1-[0:.001:.999]), [0:.001:.999]+KSdist/sqrt(N), ...
%      'r', -log(1-[0:.001:.999]), [0:.001:.999]-KSdist/sqrt(N), 'r');
%axis( [0 7 0 1] );
