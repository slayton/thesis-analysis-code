r = replay;

t = [];
dt = [];
event_len = .15;
ind = 0;
used = zeros(1,length(r.saline.inputs));
for i = 1:length(r.saline.inputs)

    dt_local =  r.saline.inputs(i).tbins(end) - r.saline.inputs(i).tbins(1);
    if dt_local > event_len
        ind = ind+1;
        t(ind) = r.saline.inputs(i).tbins(1);
        dt(ind) = dt_local;
        used(ind) = 1;
    end
end

used = logical(used);
%plot(t, r.saline.score(used), '.');


%% Regress replay score vs MUB duration <-- no relationshipedit l
x = t';
y = r.saline.score(used)';
x = [ones(size(x)), x];

out = inv(x'*x) * x'*y; % or use regress in matlab

alpha = out(1);
beta = out(2);

[b bint r rint stats] = regress(y,x);

plot(t, y, '.'); hold on;
plot(linspace(min(t),max(t),100), b(1)+b(2)*linspace(min(t),max(t),100), 'r');
stats

%{
X = t;
Y = r.saline.score(used);
V = [X, ones(size(X))];
c = V\Y;
xs = linspace(min(X),max(X),1000);
plot( X, Y, 'o' )
hold on
plot( xs, c(1)*xs + c(2) );

%figure;

%plot(dt, r.saline.score(used), '.');
\
%}