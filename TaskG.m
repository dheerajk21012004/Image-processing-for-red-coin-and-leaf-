%% Task G – Centroid, Medoid and Green Leaf Index

stats_leaf = regionprops(BM_leaf_clean,'Centroid','PixelIdxList');
stats_coin = regionprops(BM_coin_clean,'Centroid','PixelIdxList');
centroid_leaf = stats_leaf.Centroid; 
centroid_coin = stats_coin.Centroid;

% Medoid calculation for leaf
[yL,xL] = ind2sub(size(BM_leaf_clean), stats_leaf.PixelIdxList);
distL = sqrt((xL-centroid_leaf(1)).^2 + (yL-centroid_leaf(2)).^2);
[~,idL] = min(distL); medoid_leaf = [xL(idL), yL(idL)];

[yC,xC] = ind2sub(size(BM_coin_clean), stats_coin.PixelIdxList);
distC = sqrt((xC-centroid_coin(1)).^2 + (yC-centroid_coin(2)).^2);
[~,idC] = min(distC); medoid_coin = [xC(idC), yC(idC)];

% Green Leaf Index (GLI) 
R = double(I(:,:,1)); G = double(I(:,:,2)); B = double(I(:,:,3));
GLI = mean((2*G(BM_leaf_clean)-R(BM_leaf_clean)-B(BM_leaf_clean)) ./ ...
           (2*G(BM_leaf_clean)+R(BM_leaf_clean)+B(BM_leaf_clean)));

% Annotation  
figure;
imshow(I_annotated);
hold on;
plot(centroid_leaf(1),centroid_leaf(2),'rx','LineWidth',2);
plot(medoid_leaf(1),medoid_leaf(2),'bo','LineWidth',2);
plot(centroid_coin(1),centroid_coin(2),'rx','LineWidth',2);
plot(medoid_coin(1),medoid_coin(2),'bo','LineWidth',2);
text(centroid_leaf(1)+10,centroid_leaf(2),sprintf('Leaf  GLI = %.3f',GLI),...
     'Color','y','FontSize',10,'FontWeight','bold');
text(centroid_coin(1)+10,centroid_coin(2),'Coin',...
     'Color','c','FontSize',10,'FontWeight','bold');
title('Centroid (red ×), Medoid (blue o) and GLI');
hold off;
