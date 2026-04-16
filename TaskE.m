%% Task E – Separate entry wise product and RGB histogram

load('cleanMasks.mat'); 
% Entry-wise products (segmented color images) 
leaf_segmented = I .* uint8(BM_leaf_clean);  
coin_segmented = I .* uint8(BM_coin_clean); 

figure;
subplot(1,2,1); 
imshow(leaf_segmented);
title('Leaf Only (Entry-wise Product)');

subplot(1,2,2); 
imshow(coin_segmented);
title('Coin Only (Entry-wise Product)');

% RGB histograms using the cleaned masks of leaf and coin.
plotRGBHistogram(I, BM_leaf_clean, 'Leaf');
plotRGBHistogram(I, BM_coin_clean, 'Coin');

% function to create the RGB histogram 
function plotRGBHistogram(I, mask, objectName)
    % Extracting  three colour channels
    R = I(:,:,1); G = I(:,:,2); B = I(:,:,3);
    % Selecting pixels belonging to the object
    Rvals = R(mask); Gvals = G(mask); Bvals = B(mask);
    % Histogram (0–255 bins)
    bins = 0:255;
    hR = histcounts(Rvals,bins);
    hG = histcounts(Gvals,bins);
    hB = histcounts(Bvals,bins);
    % Normalise
    hR = hR / max(hR);
    hG = hG / max(hG);
    hB = hB / max(hB);
    % Plot
    figure; hold on;
    plot(bins(1:end-1),hR,'r','LineWidth',1.5);
    plot(bins(1:end-1),hG,'g','LineWidth',1.5);
    plot(bins(1:end-1),hB,'b','LineWidth',1.5);
    xlim([0 255]); ylim([0 1]);
    xlabel('Intensity (0–255)'); ylabel('Normalised Frequency');
    title(['Normalised RGB Histogram – ', objectName]);
    legend('Red','Green','Blue'); grid on; hold off;
end
