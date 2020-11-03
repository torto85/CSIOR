function [ circle ] = get_circle( radius, t )

%% GENERATE A CIRCLE
t = t(1:end-1);
x = radius * cos(t);
y = radius * sin(t);
z = 0*t;
circle = cat(1, x, y, z);

end