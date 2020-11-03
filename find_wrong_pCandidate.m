function idx = find_wrong_pCandidate ( vertex, facet, p_candidate )
% find_wrong_pCandidate returns the index of p_candidates
% wrongly selected, by checking their distance to their original facet

n_candidate = size(p_candidate, 1);
idx = false(n_candidate, 1);
for p = 1:n_candidate
    facet_points = vertex(facet(p,:),:);
    max_dist = max(pdist(facet_points))^2;
    
    dist = max(pdist2(p_candidate(p,:), facet_points));

    if dist > max_dist
        idx(p) = true;
    end
end

end