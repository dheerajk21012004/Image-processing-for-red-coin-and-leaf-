%% Task I 
clc;
clear; 
close all;

%% Example image load - image 9
folder = 'multi_leaf_images';
imageName = 'image_9.jpg';
I = imread(fullfile("C:\Users\dheer\OneDrive\Desktop\multi_leaf_images\image_9.jpg"));

figure; imshow(I);
title('Input Image – image\_9');

%%  1. Leaf segmentation using your trained mask 
[BW_multi, maskedMulti] = createMaskMulti1(I);

figure;
subplot(1,2,1); imshow(BW_multi); title('Initial Leaf Mask');
subplot(1,2,2); imshow(maskedMulti); title('Masked Output');

%% 2. Clean segmentation mask 
se = strel('disk',5);
BW_clean = imfill(BW_multi,'holes');
BW_clean = imopen(BW_clean,se);
BW_clean = imclose(BW_clean,se);
BW_clean = bwareaopen(BW_clean,1000);

figure; imshow(BW_clean);
title('Cleaned Leaf Mask');

%% 3. COIN detection using Hough Transform 
grayI = rgb2gray(I);
grayI = imadjust(grayI);

[centers, radii, metric] = imfindcircles(grayI,[20 120], ...
                                         'Sensitivity',0.92, ...
                                         'EdgeThreshold',0.05);

BW_coin = false(size(grayI));

if ~isempty(centers)
    [~, idx] = max(metric);
    coinCenter = centers(idx,:);
    coinRadius = radii(idx);

    [X,Y] = meshgrid(1:size(I,2), 1:size(I,1));
    BW_coin = (X - coinCenter(1)).^2 + (Y - coinCenter(2)).^2 <= (coinRadius+5).^2;

else
    warning('⚠ Coin not detected in image_24');
end

figure; imshow(BW_coin); title('Detected Coin Mask');

%%  4. Removing coin from leaf mask 
BW_leafOnly = BW_clean & ~BW_coin;

figure; imshow(BW_leafOnly);
title('Leaf Mask After Removing Coin');

%%  5. Labeling leaves 
BW_leafOnly = imfill(BW_leafOnly,'holes');
BW_leafOnly = bwareaopen(BW_leafOnly,1500);

[L, numLeaves] = bwlabel(BW_leafOnly);
leafStats = regionprops(L,'Area','Perimeter','BoundingBox','PixelIdxList');

figure; imshow(labeloverlay(I,L));
title(sprintf('Labelled Leaves – %d total', numLeaves));

%% 6.  all metrics (Area, Perimeter, GLI, Damage) 
 R = double(I(:,:,1)); G = double(I(:,:,2)); B = double(I(:,:,3));

GLI_vals = zeros(numLeaves,1);
area_vals = zeros(numLeaves,1);
perim_vals = zeros(numLeaves,1);
damage_vals = zeros(numLeaves,1);

% scale factor (mm per pixel)
if ~isempty(centers)
    px_to_mm = 20.3 / (2*coinRadius);
else
    px_to_mm = NaN;
end

for n = 1:numLeaves
    mask_n = (L == n);

    % GLI
    GLI_vals(n) = mean((2*G(mask_n)-R(mask_n)-B(mask_n)) ./ ...
                       (2*G(mask_n)+R(mask_n)+B(mask_n)));

    % area + perimeter
    area_vals(n)  = leafStats(n).Area * px_to_mm^2;
    perim_vals(n) = leafStats(n).Perimeter * px_to_mm;

    % damage % (convex hull loss)
    CH = bwconvhull(mask_n);
    hullArea = sum(CH(:));
    leafArea = leafStats(n).Area;
    damage_vals(n) = 100 * (hullArea - leafArea) / hullArea;
end

%% 7. FINAL ANNOTATED OUTPUT 
RGB_annot = labeloverlay(I,L);

figure; imshow(RGB_annot); hold on;
title('Final Annotated Output – image\_24');

for n = 1:numLeaves
    bb = leafStats(n).BoundingBox;

    annotationText = sprintf( ...
        'Leaf %d\nArea: %.0f mm^2\nPerim: %.1f mm\nGLI: %.2f\nDamage: %.1f%%', ...
         n, area_vals(n), perim_vals(n), GLI_vals(n), damage_vals(n));

    text(bb(1), bb(2)-15, annotationText, ...
        'Color','yellow','FontSize',9,'FontWeight','bold', ...
        'BackgroundColor','black','Margin',2);
end

