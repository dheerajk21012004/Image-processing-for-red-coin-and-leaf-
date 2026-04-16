%% Task D – Morphological and non-linear filtering of the image
se = strel('disk',5);

BM_leaf_clean = imfill(BM_leaf,'holes');
BM_leaf_clean = imopen(BM_leaf_clean,se);
BM_leaf_clean = imclose(BM_leaf_clean,se);
BM_leaf_clean = bwareaopen(BM_leaf_clean,500);

BM_coin_clean = imfill(BM_coin,'holes');
BM_coin_clean = imopen(BM_coin_clean,se);
BM_coin_clean = imclose(BM_coin_clean,se);
BM_coin_clean = bwareaopen(BM_coin_clean,500);

combinedMask_clean = BM_leaf_clean | BM_coin_clean;
segmented_clean = I .* uint8(combinedMask_clean);

figure;
subplot(1,2,1); 
imshow(BM_leaf_clean);
title('Cleaned Leaf Mask');

subplot(1,2,2); 
imshow(BM_coin_clean);
title('Cleaned Coin Mask');

figure; imshow(segmented_clean);
title('Cleaned Entry-wise Product');
save('cleanMasks.mat','BM_leaf_clean','BM_coin_clean','I');
