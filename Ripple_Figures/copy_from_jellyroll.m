
function copy_from_jellyroll(day)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  JELLY ROLL - greghale@10.121.43.47
%  ELDRIDGE   - rsx@10.121.43.163
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin==32673
    day = 21;
end

outBaseDir = sprintf('~/gilbert/01%02d13', day);
inBaseDir = sprintf('/data/gh-rsc2/day%02d', day);

if ~exist(inBaseDir,'dir')
    mkdir(inBaseDir);
end


user = 'rsx';
ip = '10.121.43.163';

cmd = sprintf('scp -r %s@%s:"', user, ip);
for i = 1:30;
    
    localdir = fullfile(inBaseDir, sprintf('t%02d', i));
    if exist( localdir, 'dir')
        continue;
    end
    
    localdir = fullfile(inBaseDir, sprintf('%02d%d', i, day));
    if exist( localdir , 'dir')
        continue;
    end
    
    
    d = sprintf('%02d%d', i, day);
    cmd = [cmd, fullfile(outBaseDir, d), ' '];
end

cmd = [cmd, fullfile(outBaseDir,'epoch.init')];
cmd = [cmd,'" ' inBaseDir];
fprintf('Executing command:\n%s\n', cmd);
system(cmd);
end
