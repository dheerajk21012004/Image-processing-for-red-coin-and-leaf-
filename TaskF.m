%% Task F – Annotating Object Boundaries

% Morphological gradient to find boundaries
se = strel('disk', 2);
leaf_boundary = imdilate(BM_leaf_clean,se) - imerode(BM_leaf_clean,se);
coin_boundary = imdilate(BM_coin_clean,se) - imerode(BM_coin_clean,se);

% Overlaying boundaries on original image
I_annotated = I;
I_annotated(:,:,1) = I_annotated(:,:,1) + uint8(255*coin_boundary); % copper border for coin
I_annotated(:,:,2) = I_annotated(:,:,2) + uint8(255*leaf_boundary); % green border for leaf

% figure for the coin and leaf
figure;
subplot(1,3,1);
imshow(leaf_boundary); 
title('Leaf Boundary');

subplot(1,3,2);
imshow(coin_boundary); 
title('Coin Boundary');
subplot(1,3,3);
imshow(I_annotated); 
title('Annotated Image with Boundaries');
