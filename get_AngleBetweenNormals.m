function angle = get_AngleBetweenNormals ( normals, v )

v = v / norm(v);

n_normal = size(normals, 1);
angle = zeros(n_normal, 1);
for i = 1:n_normal
    u = normals(i,:);
    u = u / norm(u);
    angle(i) = atan2d(norm(cross(u,v)),dot(u,v));
end

end