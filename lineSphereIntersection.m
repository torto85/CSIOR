function p = lineSphereIntersection ( line, p_line, circle_center, radius )
p = [];

a = line(1)^2 + line(2)^2 + line(3)^2;
b = 2 * line(1) * (p_line(1) - circle_center(1)) ...
    + 2 * line(2) * (p_line(2) - circle_center(2)) ...
    + 2 * line(3) * (p_line(3) - circle_center(3));
c = ( p_line(1) - circle_center(1) )^2 ...
    + ( p_line(2) - circle_center(2) )^2 ...
    + ( p_line(3) - circle_center(3) )^2 - radius^2;

delta = b^2 -4*a*c;

t = nan(2,1);
if delta >= 0
    t(1) = ( -b + sqrt(delta) ) / (2*a);
    t(2) = ( -b - sqrt(delta) ) / (2*a);
    
    x = p_line(1) + line(1) * t;
    y = p_line(2) + line(2) * t;
    z = p_line(3) + line(3) * t;
    p = cat(2, x, y, z);
end

end