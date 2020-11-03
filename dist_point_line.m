function dist=dist_point_line(P,n,Xo)

%P: the point  or Nx3 points where N is the number of points
%n: the line orientation  3x1
%Xo: a point belonging to the line  3x1
if size(P,1) < size(P,2) 
    P=P' ;
end
if size(n,1) > size(n,2) 
    n=n' ;
end
if size(Xo,1) > size(Xo,2) 
    Xo=Xo' ;
end

N = size(P,1);
ns = repmat(n,N,1);
Xos = repmat(Xo,N,1);
crs = (cross(P-Xos,ns));
normcrs = sqrt(sum(crs.*crs,2));
dist =normcrs/norm(n) ;

end