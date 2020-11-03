function [ vertex, face, rings ] = CSIOR ( original_vertex, original_face, edge_length, initial_vertex )

if size(original_vertex,1) < size(original_vertex,2)
    original_vertex = original_vertex';
    original_face = original_face';
end

%% Setting variables
if nargin < 3
    edge_length = get_AverageEdgeLength(original_vertex, original_face);
end

if nargin < 4
    P = pca(original_vertex);
    P = Intersect_Line_Surface(original_vertex, P(:,3), mean(original_vertex));
    [ ~, initial_vertex ] = min(pdist2(original_vertex, P));
end

original_edge = get_AverageEdgeLength(original_vertex, original_face);
if original_edge < edge_length
    region_size = edge_length + original_edge;
else
    region_size = original_edge;
end

geodesic_dist = perform_fast_marching_mesh(original_vertex, original_face, initial_vertex);
iter_max = max(geodesic_dist) / edge_length;    % Set to avoid infinite loop in case of resampling errors

%% FIRST HEXAGON
radius = sqrt( edge_length^2 - (edge_length/2)^2 );
hexagon = get_circle(edge_length, 0:pi/3:2*pi);
hexagon = project_hexagon(original_vertex(initial_vertex,:), original_vertex, region_size, hexagon);

vertex = cat(1, ...
    original_vertex(initial_vertex,:), ...
    hexagon);
f = 2:7;
face = cat(2, ones(6,1), ...
    f', circshift(f',-1));
ring_count = 1;
rings{ring_count} = 1:size(face,1);

vertex_valence = ones(7,1);
vertex_valence(1) = 6;
vertex_valence(2:end) = 2;

%% ITERATIVE RESAMPLING
facetIn = face;
n_face = 0;
iter = 0;
while n_face ~= size(face,1) && iter <= iter_max
    iter = iter + 1;
    n_face = size(face,1);
    facetOut = [];
    
    %% DISCOVER NEW FacetOUT
    facetIn_used = true(size(facetIn,1), 1);
    for fin = 1:size(facetIn,1)
        %% Discover New Vertex
        pIn = vertex(facetIn(fin, 1), :);
        pOut1 = vertex(facetIn(fin, 2), :);
        pOut2 = vertex(facetIn(fin, 3), :);

        if ~isempty(facetOut) ...
                && pdist2(pOut2, vertex(facetOut(end,2),:)) <= edge_length^2
            %% If previusly discovered vertex is close to FacetIn
            %  then connect it
            facetOut = cat(1, facetOut, ...
                cat(2, facetIn(fin,2), facetOut(end,2), facetIn(fin,3)));
            vertex_valence = update_valence(vertex_valence, facetOut(end,:));
        else
            %% Overwise use circle intersection
            [ found, vertex, facetOut, exception ] = intersectCircleMesh(vertex, facetIn, ...
                facetOut, fin, original_vertex, original_face, geodesic_dist, edge_length, region_size);
            
            run = 1;
            while ~found && exception && run <= 3
                if ~exist('new_edge', 'var')
                    new_edge = edge_length;
                    new_region = region_size;
                end
                new_edge = new_edge * 1.5;
                new_region = new_region * 1.5;
                run = run + 1;
                [ found, vertex, facetOut, exception ] = intersectCircleMesh(vertex, facetIn, ...
                    facetOut, fin, original_vertex, original_face, geodesic_dist, new_edge, new_region);
            end
            clear new_edge new_region;
            
            if found
                vertex_valence = update_valence(vertex_valence, facetOut(end,:));
                if fin > 2 && facetIn(fin,2) == facetIn(fin-1,3) ...
                        && facetIn(fin-1,2) == facetIn(fin-2,3) ...
                        && ~facetIn_used(fin-1) && facetIn_used(fin-2)
                    vertex = cat(1, vertex, mean(cat(1, vertex(end,:), vertex(end-1,:))));
                    new_facet = cat(2, facetIn(fin-1,2), size(vertex,1), facetIn(fin-1,3));
                    vertex_valence = update_valence(vertex_valence, new_facet);
                    facetOut = cat(1, facetOut(1:end-1,:), new_facet, facetOut(end,:));
                    facetIn_used(fin-1) = true;
                end
            else
                facetIn_used(fin) = false;
            end
        end
        
    end
    
    %% FIND FacetIN
    n_fout = size(facetOut,1);
    facetOut_shift = circshift(facetOut, -1, 1);
    facetIn_new = [];
    prev_p = [];
    p_idx = [];
    for fout = 1:n_fout
        if facetOut(fout,3) == facetOut_shift(fout,1) && ...
                facetOut(fout,2) ~= facetOut_shift(fout,2)
            %% If consecutive facetOut then connect them
            if (vertex_valence(facetOut(fout,3)) >= 5 ...
                    && pdist2(vertex(facetOut(fout,2),:), ...
                        vertex(facetOut_shift(fout,2),:)) < (edge_length*1.5)^2 ) ...
                    || pdist2(vertex(facetOut(fout,2),:), ...
                        vertex(facetOut_shift(fout,2),:)) <= (edge_length)^2
                %% If valance 5 then direct connection 
                %  or consecutive FacetOUT are close enough
                if vertex_valence(facetOut(fout,3))<5 && pdist2(vertex(facetOut(fout,2),:), ...
                        vertex(facetOut_shift(fout,2),:)) <= (edge_length)^2 
                    pause(.1);
                end
                new_facet = cat(2, facetOut(fout,3), facetOut(fout,2), facetOut_shift(fout,2));
                vertex_valence = update_valence(vertex_valence, new_facet);
                
                [ facetIn_new, facet_add ] = fix_facetIn_all(vertex, facetIn_new, new_facet, edge_length);
                face = cat(1, face, facetOut(fout,:), facet_add, new_facet);
                for i = 1:size(facet_add,1)
                    vertex_valence = update_valence(vertex_valence, facet_add(i,:));
                end

            else
                %% If valance not 5 then add a point in the middle
                %  or consecutive FacetOut are distant
                p_candidate1 = intersectCircleMesh_slim(vertex, facetOut(fout,:), ...
                    original_vertex, original_face, edge_length, region_size);
                p_candidate2 = intersectCircleMesh_slim(vertex, circshift(facetOut_shift(fout,:), 1, 2), ...
                    original_vertex, original_face, edge_length, region_size);
             
                if size(p_candidate1,1) > 1
                    [ ~, idx ] = min(pdist2(p_candidate1, mean(cat(1, ...
                        vertex(facetOut(fout,2),:), vertex(facetOut_shift(fout,2),:)))));
                    p_candidate1 = p_candidate1(idx, :);
                end
                if size(p_candidate2,1) > 1
                    [ ~, idx ] = min(pdist2(p_candidate2, mean(cat(1, ...
                        vertex(facetOut(fout,2),:), vertex(facetOut_shift(fout,2),:)))));
                    p_candidate2 = p_candidate2(idx, :);
                end
                if isempty(p_candidate1)
                    p = p_candidate2;
                elseif isempty(p_candidate2)
                    p = p_candidate1;
                else
                    p = ( p_candidate1 + p_candidate2 ) / 2;
                end
                
                if isempty(p)
                    face = cat(1, face, facetOut(fout,:));
                    continue;
                end
                
                if ~isempty(p_idx)
                    [ p_min, idx ] = min(pdist2(prev_p, p));
                end
                if ~isempty(p_idx) ...
                        && p_min < (radius/2)^2
                    %% New point is close to a previous one (exception)
                    vertex(p_idx(idx),:) = mean(cat(1, ...
                        vertex(p_idx(idx),:), p));
                    p_idx = cat(1, p_idx, p_idx(idx));
                else
                    vertex = cat(1, vertex, p);
                    prev_p = cat(1, prev_p, p);
                    p_idx = cat(1, p_idx, size(vertex,1));
                end
                
                new_facet = cat(1, ...
                    cat(2, facetOut(fout,3), facetOut(fout,2), p_idx(end)), ...
                    cat(2, facetOut(fout,3), p_idx(end), facetOut_shift(fout,2)));
                    
                vertex_valence = update_valence(vertex_valence, new_facet(1,:));
                vertex_valence = update_valence(vertex_valence, new_facet(2,:));
                                
                if numel(p_idx) > 1  ...
                        && p_min < (radius/2)^2
                    %% New point is close to a previous one (exception)
                    facetIn_new = cat(1, facetIn_new(1:end-1,:), new_facet(2,:));
                    face = cat(1, face, facetOut(fout,:), new_facet);
                else
                    [ facetIn_new, facet_add ] = fix_facetIn_all(vertex, facetIn_new, new_facet, edge_length);
                    face = cat(1, face, facetOut(fout,:), facet_add, new_facet);
                    for i = 1:size(facet_add,1)
                        vertex_valence = update_valence(vertex_valence, facet_add(i,:));
                    end
                end
            end
        else
            face = cat(1, face, facetOut(fout,:));
        end
        if fout == n_fout && ~isempty(facetIn_new)
            %% exception for the last FacetIn
            [ fixed, facet_fixed ] = fix_facetIn(vertex, facetIn_new(end,:), facetIn_new(1,:), edge_length);
            if fixed
                facetIn_new = cat(1, facetIn_new(2:end-1,:));
                vertex_valence = update_valence(vertex_valence, facet_fixed);
                [ facetIn_new, facet_add ] = fix_facetIn_all(vertex, facetIn_new, facet_fixed, edge_length);
                face = cat(1, face, facet_add, facet_fixed);
                for i = 1:size(facet_add,1)
                    vertex_valence = update_valence(vertex_valence, facet_add(i,:));
                end
            end
        end

    end
    facetIn = facetIn_new;
    ring_count = ring_count + 1;
    rings{ring_count} = n_face+1:size(face,1);
end
end