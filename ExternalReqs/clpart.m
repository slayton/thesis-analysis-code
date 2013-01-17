function [cls] = clpart(varargin)
% CLPART partition a parm cluster by radial partitioning

% todo

a = struct('cl', [],...
           'timewin', [-Inf Inf],...
           'uvthresh', -Inf,...
           'thresh_method', 'radius',... % or 'anychannel'
           'pkfields', {{'t_px_uv' 't_py_uv' 't_pa_uv' 't_pb_uv'}},...
           'radiusfield', 'radius_uv',...
           'posifield', 'posi',...
           'keepfields', {{'time' 'posi'}},... % fields to keep in new cls
           'r_splits', [0 100],... % default is no splits
           'ang_splits', [0 100]); % default is no splits

a = parseArgsLite(varargin,a);

% how many partitions are we making?
n_parts = (length(a.ang_splits)-1)^3 * (length(a.r_splits)-1);
if n_parts < 1,
  error(['''ang_splits'' and ''r_splits'' must have at least 2 elements ' ...
         'each']);
end

% timewin
f.time = getepd(a.cl, 'time');
goodi_time = f.time >= a.timewin(1) & f.time <= a.timewin(2);

% get spike peak amplitudes
f.pks = getepdi(a.cl, goodi_time, a.pkfields{:});

cldat = getepdi(a.cl, goodi_time, a.keepfields{:});

% convert peak amplitudes to hyperspherical coords (3 angles + radial distance):
%
% r = sqrt(x^2 + y^2 + a^2 + b^2)
% x = r cos(alpha)
% y = r sin(alpha) cos(beta)
% a = r sin(alpha) sin(beta) cos(gamma)
% b = r sin(alpha) sin(beta) sin(gamma)

f.r = sqrt(sum(f.pks.^2 , 2));

f.alpha = zeros(size(f.time));
f.beta = zeros(size(f.time));
f.gamma = zeros(size(f.time));
f.part = int32(zeros(size(f.time)));
			  
f.alpha = acos(double(f.pks(:,1)) ./ f.r);
sin_alpha = sin(double(f.alpha));

f.beta = acos(double(f.pks(:,2)) ./ (f.r .* sin_alpha));
sin_beta = sin(double(f.beta));

f.gamma = acos(double(f.pks(:,3)) ./ (f.r .* sin_alpha .* sin_beta));

switch(a.thresh_method)
 case 'radius'
  goodi_th = f.r >= a.uvthresh;
 case 'anychannel',
  goodi_th = any(f.pks >= a.uvthresh,2);
 otherwise
  error('unsupported ''thresh_method''');
end

% only points in first quadrant are used (to make partitioning work)
goodi_th = goodi_th & all(f.pks > 0, 2);

% get the percentile values to use in partitioning
pct_r = prctile(f.r(goodi_th), a.r_splits);

pct_alpha = prctile(f.alpha(goodi_th), a.ang_splits);

pct_beta = prctile(f.beta(goodi_th), a.ang_splits);

pct_gamma = prctile(f.gamma(goodi_th), a.ang_splits);

% discard points outside requested percentile ranges ('splits')
goodi_val = f.r > pct_r(1) & f.r < pct_r(end);
goodi_val = goodi_val & (f.alpha > pct_alpha(1) & f.alpha < pct_alpha(end));
goodi_val = goodi_val & (f.beta > pct_beta(1) & f.beta < pct_beta(end));
goodi_val = goodi_val & (f.gamma > pct_gamma(1) & f.gamma < pct_gamma(end));

%% select only points that satisfy thresh and are within requested prctile ranges
goodi = goodi_th & goodi_val;

f.r = f.r(goodi);
f.alpha = f.alpha(goodi);
f.beta = f.beta(goodi);
f.gamma = f.gamma(goodi);
cldat = cldat(goodi,:);


%% OK Partition!
f.part = zeros(size(f.r));

% principle here is of a base(splits) number, with the value of each of
% three 'digits' (alpha/beta/gamma) assigned by the angle bin the spike
% falls into So if there are 4 bins per angle (e.g. ang_splits = [0 25 50 75
% 100]), there will be 4^3=64 possible partitions, and a spike might be in
% partition 032 = 0*(4^0) + 3*(4^1) + 2*(4^2) = 44
%
% similar logic for radius bins, which are tacked on at the end
%
% Note that partitions will be zero-indexed!


mult_a = length(a.ang_splits)-1;
for k = 2:mult_a % if only one bin, leave zeros
  f.part = f.part + ...
           ((f.alpha >= pct_alpha(k) & f.alpha < pct_alpha(k+1)) * (k-1)) + ...
           ((f.beta >= pct_beta(k) & f.beta < pct_beta(k+1)) * mult_a * (k-1)) + ...
           ((f.gamma >= pct_gamma(k) & f.gamma < pct_gamma(k+1)) * (mult_a .^2) * (k-1));
end

mult_r = length(a.r_splits)-1;
for k = 2:mult_r % if only one bin, don't add
  f.part = (f.r >= pct_r(k) & f.r < pct_r(k+1)) * (mult_a^3) * (k-1);
end


for k = 1:n_parts
  % select spikes in each partition
  cli = (f.part == k-1); % partitions are zero-indexed!
  cls(k).dat =  cldat(cli,:);
  cls(k).flds = a.keepfields;
  cls(k).name = [a.cl.name '_part_' num2str(k)];
end

