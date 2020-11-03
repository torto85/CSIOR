function [ edge_length, dist ] = get_AverageEdgeLength ( vertex, face )

if size(vertex,1) < size(vertex,2)
    vertex = vertex';
end
if size(face,1) < size(face,2)
    face = face';
end

[ ~, ~, edges ] = find_mesh_edges(face);

v1 = vertex(edges(:,1),:);
v2 = vertex(edges(:,2),:);

dist = sqrt(sum(( v1 - v2 ) .^ 2, 2));
edge_length = mean(dist);

end