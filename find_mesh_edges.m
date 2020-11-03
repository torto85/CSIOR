function [ singleEdgeVertex, singleUseEdges, edges, doubleUseEdges, tripleUseEdges ] = find_mesh_edges ( face )
%% EDGES LIST
edges = sort(cat(1, face(:,1:2), face(:,2:3), face(:,[3 1])),2);
[ unqEdges, ~, edgeNo ] = unique(edges, 'rows');

%% SINGLE EDGES
h = hist(edgeNo, 1:max(edgeNo));


singleUseEdgesIdx = h < 2;
singleUseEdges = unqEdges(singleUseEdgesIdx,:);
singleEdgeVertex = unique(singleUseEdges(:));

%% DOUBLE EDGES
doubleUseEdgesIdx = h == 2;
doubleUseEdges = unqEdges(doubleUseEdgesIdx,:);

%% TRIPLE EDGES
tripleUseEdgesIdx = h > 2;
tripleUseEdges = unqEdges(tripleUseEdgesIdx,:);

end
