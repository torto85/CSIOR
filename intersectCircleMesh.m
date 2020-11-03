function [ found, vertex, facetOut, exception ] = intersectCircleMesh ( vertex, facetIn, facetOut, fin, original_vertex, original_face, geodesic_dist, edge_length, region_size )

found = true;
exception = false;
radius = sqrt( edge_length^2 - (edge_length/2)^2 );
original_vertex_idx = transpose(1:size(original_vertex,1));

pIn = vertex(facetIn(fin, 1), :);
pOut1 = vertex(facetIn(fin, 2), :);
pOut2 = vertex(facetIn(fin, 3), :);

mid_point = ( pOut1 + pOut2 ) / 2;
circle_normal = (pOut2 - pOut1) / norm(pOut2 - pOut1);
d_circle = dot(circle_normal, mid_point);


%% Select Region
dist = pdist2(original_vertex, mid_point);
idx = dist < region_size^2;
while sum(idx) < 10 %MAYBE IS NOT NEEDED
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

%         ab(abs(ab)<.00000001) = 0;
%         ac(abs(ac)<.00000001) = 0;
%         cb(abs(cb)<.00000001) = 0;

        if sign(ab(3)) == sign(ac(3)) ...
                && sign(ac(3)) == sign(cb(3))
            ab = cross(p3-p2,p1-p2);
            ac = cross(p3-p2,points(p,:)-p2);
            cb = cross(points(p,:)-p2,p1-p2);

%             ab(abs(ab)<.00000001) = 0;
%             ac(abs(ac)<.00000001) = 0;
%             cb(abs(cb)<.00000001) = 0;

            if sign(ab(3)) == sign(ac(3)) && ...
                    sign(ac(3)) == sign(cb(3))
                p_candidate = cat(1, p_candidate, points(p,:));
                p_candidate_facet = cat(1, p_candidate_facet, f);
            end
        end 
    end
end

if isempty(p_candidate)
    exception = true;
    found = false;
    return;
end

dist = pdist2(p_candidate, pIn);
if size(p_candidate,1) <= 2
    if size(p_candidate,1) == 1 || ( size(p_candidate,1) > 1 ...
            && abs(dist(1)-dist(2)) > radius^2 )
        %% Easy to choose the new point
        [ dist, idx ] = max(dist);
        if dist < radius^2
            %% If next to the border
            found = false;
            return;
        else
            p = p_candidate(idx,:);
        end
    else
        %% Hard to choose the new point, then use max geodesic_dist
        if numel(dist) > 1 && ( isempty(facetOut) || ( ~isempty(facetOut) ...
                && facetOut(end,3) == facetIn(fin,2) ) )
            dist = geodesic_dist(region_facet(p_candidate_facet,:));
            [ ~, idx ] = max(mean(dist,2));
            p = p_candidate(idx,:);
        elseif numel(dist) > 1 && ( ~isempty(facetOut) ...
                || facetOut(end,3) == facetIn(fin,2) )
            dist = pdist2(p_candidate, vertex(facetOut(end,2),:));
            [ ~, idx ] = min(dist);
            p = p_candidate(idx,:);
        else
            %% If next to the border
            found = false;
            return;
        end
    end
else
    %% More than 2 candidate (error while intersecting the circle)
    idx = dist > radius^2;
    p_candidate = p_candidate(idx,:);
    p_candidate_facet = p_candidate_facet(idx,:);
    if size(p_candidate,1) > 1
        idx = find_wrong_pCandidate(original_vertex, ...
            region_facet(p_candidate_facet,:), p_candidate);
        p_candidate = p_candidate(~idx,:);
        p_candidate_facet = p_candidate_facet(~idx,:);
    end
    if size(p_candidate,1) > 1
        if isempty(facetOut)
            idx = find_best_pCandidate(original_vertex, region_facet, ...
                p_candidate, p_candidate_facet, mid_point);
        else
            idx = find_best_pCandidate(original_vertex, region_facet, ...
                p_candidate, p_candidate_facet, vertex(facetOut(end,2),:));
        end

        p = p_candidate(idx,:);
    elseif isempty(p_candidate)
        %% If next to the border
        found = false;
        return;
    else
        p = p_candidate;
    end
end
    
if pdist2(p, vertex(end,:)) <= (edge_length/2)^2
    %% Merge the new point with the previous
    vertex(end,:) = mean(cat(1, p, vertex(end,:)));
    facetOut = cat(1, facetOut, ...
        cat(2, facetIn(fin,2), size(vertex,1), facetIn(fin,3)));
elseif ~isempty(facetOut) && fin > size(facetIn,1)-2 && ...
        pdist2(p, vertex(facetOut(1,2),:)) <= (edge_length/2)^2
    %% Merge with the first FacetOut (exception)
    vertex(facetOut(1,2),:) = mean(cat(1, ...
        vertex(facetOut(1,2),:), p));
    facetOut = cat(1, facetOut, ...
        cat(2, facetIn(fin,2), facetOut(1,2), facetIn(fin,3)));    
else
    %% Add the new point
    vertex = cat(1, vertex, p);
    facetOut = cat(1, facetOut, ...
        cat(2, facetIn(fin,2), size(vertex,1), facetIn(fin,3)));
end

end