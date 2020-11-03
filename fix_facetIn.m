function [ fixed, new_facet ] = fix_facetIn ( vertex, facet1, facet2, length )

fixed = false;
new_facet = [];

if facet1(3) == facet2(2) && facet1(1) ~= facet2(1)
    edge1 = vertex(facet1(3),:) - vertex(facet1(2),:);
    edge2 = vertex(facet2(2),:) - vertex(facet2(3),:);
    edge1 = edge1 / norm(edge1);
    edge2 = edge2 / norm(edge2);

    angle = get_AngleBetweenNormals(edge1, edge2);
    if angle <= 105
%         p1 = vertex(facet1(2),:);
%         p2 = vertex(facet2(3),:);
%         if sqrt(pdist2(p1,p2)) < 2.4338
        p11 = vertex(facet1(1),:);
        p12 = vertex(facet1(2),:);
        p13 = vertex(facet1(3),:);
        p21 = vertex(facet2(1),:);
        p22 = vertex(facet2(2),:);
        p23 = vertex(facet2(3),:);
        normal1 = cross(p12-p11, p13-p11);
        normal2 = cross(p22-p21, p23-p21);
        normal1 = normal1 / norm(normal1);
        normal2 = normal2 / norm(normal2);
        
        angle = get_AngleBetweenNormals(normal1, normal2);
        if angle < 45 || pdist2(p12, p23) < (length*1.2)^2
            new_facet = cat(2, facet1(3), facet1(2), facet2(3));
            fixed = true;
        else
%             pause(.1)
        end
    end
end


end