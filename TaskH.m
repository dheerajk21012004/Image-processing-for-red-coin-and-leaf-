%% Task H – Morphometric Analysis (with better spacing)
coin_stats = regionprops(BM_coin_clean,'EquivDiameter');
coin_diam_px = coin_stats.EquivDiameter;
coin_diam_mm = 20.3;                     % UK 1p coin diameter on google
px_to_mm = coin_diam_mm / coin_diam_px;  % scale factor

leaf_stats = regionprops(BM_leaf_clean,'MajorAxisLength','MinorAxisLength', ...
                         'Area','Perimeter','BoundingBox','Centroid');
L = leaf_stats.MajorAxisLength * px_to_mm;
W = leaf_stats.MinorAxisLength * px_to_mm;
A = leaf_stats.Area * px_to_mm^2;
P = leaf_stats.Perimeter * px_to_mm;

% Displaying and annotating
figure;
imshow(I_annotated);
hold on;

% Bounding box and measurement lines
rectangle('Position',leaf_stats.BoundingBox,'EdgeColor','y','LineWidth',1.5);
cx = leaf_stats.Centroid(1); cy = leaf_stats.Centroid(2);
bb = leaf_stats.BoundingBox;
line([bb(1) bb(1)+bb(3)],[cy cy],'Color','m','LineWidth',2); % width
line([cx cx],[bb(2) bb(2)+bb(4)],'Color','c','LineWidth',2); % length

% Adding annotation text with vertical spacing 
yStart = 40;         % top margin in pixels
lineSpacing = 25;    % vertical gap between text lines
xPos = 30;           % horizontal offset

text(xPos, yStart,       sprintf('Leaf Length     = %.2f mm',L), ...
     'Color','yellow','FontSize',11,'FontWeight','bold','Interpreter','none');
text(xPos, yStart+lineSpacing, sprintf('Leaf Width      = %.2f mm',W), ...
     'Color','yellow','FontSize',11,'FontWeight','bold','Interpreter','none');
text(xPos, yStart+2*lineSpacing, sprintf('Leaf Area       = %.2f mm²',A), ...
     'Color','yellow','FontSize',11,'FontWeight','bold','Interpreter','none');
text(xPos, yStart+3*lineSpacing, sprintf('Leaf Perimeter  = %.2f mm',P), ...
     'Color','yellow','FontSize',11,'FontWeight','bold','Interpreter','none');
text(xPos, yStart+4*lineSpacing, sprintf('Scale Factor    = %.3f mm/pixel',px_to_mm), ...
     'Color','cyan','FontSize',11,'FontWeight','bold','Interpreter','none');

title('Leaf Morphometric Measurements (Scaled in mm)');
hold off;
