function idx = find_best_pCandidate ( vertex, facet, p_candidate, p_candidate_facet, p_ref )
% find_best_pCandidate finds the best p_candidate

[~,idx]=min(pdist2(p_candidate,p_ref));

% n_candidate = size(p_candidate, 1);
% 
% dist = pdist2(p_ref, vertex);
% [ ~, p_ref ] = min(dist);
% 
% dist = perform_fast_marching_mesh(vertex, facet, p_ref);
% 
% geod_dist_candidate = zeros(n_candidate, 1);
% for p = 1:n_candidate
%     geod_dist_candidate(p) = mean(dist(facet(p_candidate_facet(p),:)));
% end
% 
% [ ~, idx ] = min(geod_dist_candidate);


end