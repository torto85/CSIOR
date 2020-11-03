function vertex_valence = update_valence ( vertex_valence, facet )

if any(facet > size(vertex_valence,1))
    vertex_valence = cat(1, vertex_valence, 0);
end

vertex_valence(facet) = vertex_valence(facet) + 1;
end
