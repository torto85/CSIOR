function [ pt, id ] = Intersect_Line_Surface(P,n,Xo)
%return the closest point,  in the set of pounts P,
% to the line passing by Xo and coinear to the vector n

dists = abs(dist_point_line(P,n,Xo)) ;
[~,id]= min(dists);
pt=P(id,:);
end