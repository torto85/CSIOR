function [ p_candidate ] = intersectCircleMesh_slim ( vertex, facet, original_vertex, original_face, edge_length, region_size )

radius = sqrt( edge_length^2 - (edge_length/2)^2 );
original_vertex_idx = transpose(1:size(original_vertex,1));

pIn = vertex(facet(1), :);
pOut1 = vertex(facet(2), :);
pOut2 = vertex(facet(3), :);

mid_point = ( pOut1 + pOut2 ) / 2;
circle_normal = (pOut2 - pOut1) / norm(pOut2 - pOut1);
d_circle = dot(circle_normal, mid_point);


%% Select Region
dist = pdist2(original_vertex, mid_point);
idx = dist < region_size^2;
while sum(idx) < 20 %MAYBE IS NOT NEEDED
    %% increase region size if not enough points
    if ~exist('new_region_size', 'var')
        new_region_size = region_size;
    end
    new_region_size = new_region_size*1.5;
    idx = dist < new_region_size;
end
clear new_region_size

region_facet = original_vertex_idx(idx);
region_facet = any(ismember(original_face, region_facet), 2);
region_facet = original_face(region_facet,:);

%% Find plane/circle intersection for each region_facet
p_candidate = [];
p_candidate_facet = [];
for f = 1:size(region_facet,1)
    p1 = original_vertex(region_facet(f,1),:);
    p2 = original_vertex(region_facet(f,2),:);
    p3 = original_vertex(region_facet(f,3),:);

    facet_normal = cross(p2-p1, p3-p1);
    facet_normal = facet_normal/norm(facet_normal);
    d_facet = dot(p1, facet_normal);

    p = threePlaneIntersec(facet_normal, d_facet, circle_normal, d_circle);
    line = cross(facet_normal, circle_normal);

    points = lineSphereIntersection(line, p, mid_point, radius);

    for p = 1:size(points,1)
        ab = cross(p2-p1,p3-p1);
        ac = cross(p2-p1,points(p,:)-p1);
        cb = cross(points(p,:)-p1,p3-p1);

        ab(abs(ab)<.00000001) = 0;
        ac(abs(ac)<.00000001) = 0;
        cb(abs(cb)<.00000001) = 0;

        if sign(ab(3)) == sign(ac(3)) ...
                && sign(ac(3)) == sign(cb(3))
            ab = cross(p3-p2,p1-p2);
            ac = cross(p3-p2,points(p,:)-p2);
            cb = cross(points(p,:)-p2,p1-p2);

            ab(abs(ab)<.00000001) = 0;
            ac(abs(ac)<.00000001) = 0;
            cb(abs(cb)<.00000001) = 0;

            if sign(ab(3)) == sign(ac(3)) && ...
                    sign(ac(3)) == sign(cb(3))
                p_candidate = cat(1, p_candidate, points(p,:));
                p_candidate_facet = cat(1, p_candidate_facet, f);
            end
        end 
    end
end

if isempty(p_candidate)
    return;
end

idx = pdist2(p_candidate, pIn) >= radius^2;
p_candidate = p_candidate(idx,:);


end