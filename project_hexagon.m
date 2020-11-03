function [ hexagon ] = project_hexagon ( center_point, vertex, region_size, hexagon )

transpose = false;
if size(vertex,1) > size(vertex,2)
    center_point = center_point';
    vertex = vertex';
    transpose = true;
end

vertex = vertex - repmat(center_point, 1, size(vertex,2));
dist = sum(vertex.^2, 1) .^ (1/2);
idx = dist < region_size;

while sum(idx) < 20 
    %% increase region size if not enough points
    if ~exist('new_region_size', 'var')
        new_region_size = region_size;
    end
    new_region_size = new_region_size*2;
    idx = dist < new_region_size;
end
clear new_region_size

vertex = vertex(:,idx);

%% ROTO-TRANSLATION
V = pca(vertex');
vertex = V'*vertex;

%% INTERPOLATION AND PROJECTION
x = vertex(1,:);
y = vertex(2,:);
z = vertex(3,:);
F = scatteredInterpolant(x', y', z', 'natural');

X1 = hexagon(1,:);
Y1 = hexagon(2,:);
Z1 = F(X1,Y1);

hexagon = cat(1, X1, Y1, Z1);

hexagon = V'\hexagon;
hexagon = hexagon + repmat(center_point, 1, size(hexagon,2));

if transpose
    hexagon = hexagon';
end

end