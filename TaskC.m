clear all;
close all;
clc;
%% Task C – Thresholding to isolate objects of interest which is leaf and coin
I = imread('leaf_and_coin.jpg');
figure; imshow(I); title('Original Image');

% Binary masks from Color Thresholder functions
[BM_leaf, masked_Leaf] = createMask(I);
[BM_coin, masked_Coin] = createMaskcoin(I);

% Display
figure;
subplot(2,2,1); imshow(BM_leaf);
title('Leaf Binary Mask');

subplot(2,2,2); imshow(masked_Leaf);
title('Segmented Leaf');

subplot(2,2,3); imshow(BM_coin); 
title('Coin Binary Mask');

subplot(2,2,4); imshow(masked_Coin);
title('Segmented Coin');

% Entry-wise product of union of both masks
combinedMask = BM_leaf | BM_coin;
segmented_image = I .* uint8(combinedMask);
figure;
imshow(segmented_image);
title('Segmented Coin and Leaf (Entry-wise Product)');
