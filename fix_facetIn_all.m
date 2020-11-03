function [ facetIn, facet_add ] = fix_facetIn_all ( vertex, facetIn, new_facet, length )

facet_add = [];

if ~isempty(facetIn)
    [ fixed, facet_fixed ] = fix_facetIn(vertex, facetIn(end,:), new_facet(1,:), length);
    
    while fixed
        if size(facetIn,1) > 1
            facetIn = cat(1, facetIn(1:end-1,:));
            facet_add = cat(1, facet_add, facet_fixed);
            [ fixed, facet_fixed ] = fix_facetIn(vertex, facetIn(end,:), facet_fixed, length);
        else
            facetIn = [];
            facet_add = cat(1, facet_add, facet_fixed);
            fixed = false;
        end
    end
    

end

if isempty(facet_add)
    facetIn = cat(1, facetIn, new_facet(1,:));
else
    facetIn = cat(1, facetIn, facet_add(end,:));
end

if size(new_facet,1) > 1
    [ facetIn, facet_add2 ] = fix_facetIn_all(vertex, facetIn, new_facet(2,:), length);
    facet_add = cat(1, facet_add, facet_add2);
end

end