function p = threePlaneIntersec ( n1, d1, n2, d2, n3, d3 )

if nargin < 6
    n3 = [ 0, 1, 0 ];
    d3 = 0;
end

A = cat(1, n1, n2, n3);
detA = det(A);
d = cat(1, d1, d2, d3);

if detA ~= 0
    Ax = A;
    Ax(:,1) = d;
    Ay = A;
    Ay(:,2) = d;
    Az = A;
    Az(:,3) = d;
    
    p = cat(2, det(Ax)/detA, det(Ay)/detA, det(Az)/detA);
else
%     warning('No threePlaneIntersec');
    rng(2);
    n3 = rand(1,3);
    p = threePlaneIntersec(n1, d1, n2, d2, n3, d3);
end


end