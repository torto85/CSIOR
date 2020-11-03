[ original_vertex, original_face ] = read_off('towel1_2_a_s10000a.off');

edge_length = 2.5;
[ vertex, face, rings ] = CSIOR(original_vertex, original_face, edge_length);

%%
color = [ .8 .8 .8 ];
orderedColor = zeros(size(face, 1), 1);
for r = 1:numel(rings)
    orderedColor(rings{r}) = r;
end
orderedColor = mod(10 * orderedColor/max(orderedColor), 1);

figure('units', 'normalized', 'outerposition', [0 0 1 1]);
set(gcf,'color','white')
subplot(1, 2, 1);
patch('vertices', original_vertex', 'faces', original_face', ...
    'FaceVertexCData', color, ...
    'FaceColor', 'flat', ...
    'FaceLighting', 'flat', ...
    'EdgeColor', [ .3 .3 .3 ]);
camlight infinite;
axis equal;
axis tight;
axis off;
view([0 1 1]);
title('Original Mesh')
    
subplot(1, 2, 2);
patch('vertices', vertex, 'faces', face, ...
    'FaceVertexCData', color, ...
    'FaceColor', 'flat', ...
    'FaceLighting', 'flat', ...
    'EdgeColor', [ .3 .3 .3 ]);
camlight infinite;
axis equal;
axis tight;
axis off;
view([0 1 1]);
title('CSIOR');

cameratoolbar;

%%
figure('units', 'normalized', 'outerposition', [0 0 1 1]);
set(gcf,'color','white')
subplot(1, 2, 1);
patch('vertices', original_vertex', 'faces', original_face', ...
    'FaceVertexCData', color, ...
    'FaceColor', 'flat', ...
    'FaceLighting', 'none', ...
    'EdgeColor', [ .3 .3 .3 ]);
camlight infinite;
axis equal;
axis tight;
axis off;
view([0 1 1]);
zoom(3);
title('Original Mesh (Tessellation zoom)')

subplot(1, 2, 2);
patch('vertices', vertex, 'faces', face, ...
    'FaceVertexCData', orderedColor, ...
    'FaceColor', 'flat', ...
    'FaceLighting', 'none', ...
    'EdgeColor', [ .3 .3 .3 ]);
camlight infinite;
axis equal;
axis tight;
axis off;
view([0 1 1]);
zoom(3);
title('CSIOR (Ordedered Tessellation zoom)')

cameratoolbar;
