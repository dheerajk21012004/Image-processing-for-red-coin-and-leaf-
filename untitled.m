%% Task I – Multi-Leaf Analysis 

clc; 
clear; 
close all;

imageFolder = "C:\Users\dheer\OneDrive\Desktop\multi_leaf_images";
imageFiles = dir(fullfile(imageFolder,'*.jpg'))

length(imageFiles)
coin_diam_mm = 20.3;                    
results = [];                           

for k = 1:length(imageFiles)
    fname = imageFiles(k).name;
    fprintf('\nProcessing %s\n', fname);
    I = imread(fullfile(imageFolder, fname));

    %%  1. Segment leaves using your Color Thresholder function
    %% created mask using colour threshold app. 
    [BW_multi, maskedMulti] = createMaskMulti1(I);

    %%  2. mask cleaning
    se = strel('disk',5);
    BW_multi = imfill(BW_multi,'holes');
    BW_multi = imopen(BW_multi,se);
    BW_multi = imclose(BW_multi,se);
    BW_multi = bwareaopen(BW_multi,1000);

    %%  3.Hough Transformation forthe coin detection and removal
    grayI = rgb2gray(I);
    grayI = imadjust(grayI);

    % Detection of circular coin
    [centers, radii, metric] = imfindcircles(grayI,[20 120], ...
                                             'Sensitivity',0.92, ...
                                             'EdgeThreshold',0.05);

    BW_coin = false(size(grayI));

    if ~isempty(centers)
        fprintf("Coin detected using Hough Transform.\n");

        % strongest circle
        [~, idx] = max(metric);
        coinCenter = centers(idx,:);
        coinRadius = radii(idx);

        % building circular mask
        [X,Y] = meshgrid(1:size(I,2), 1:size(I,1));
        BW_coin = (X - coinCenter(1)).^2 + (Y - coinCenter(2)).^2 <= (coinRadius + 5).^2;

    else
        warning('⚠️  No coin detected by Hough Transform in %s. Scaling skipped.', fname);
    end

    %% Removing the coin completely from leaf mask 
    BW_multi = BW_multi & ~BW_coin;

    %% 4. Relabeling leaves after coin removal 
    BW_multi = imfill(BW_multi,'holes');
    BW_multi = bwareaopen(BW_multi,1500);
    
    [L, numLeaves] = bwlabel(BW_multi);
    fprintf('Detected %d leaves (after Hough-based coin removal)\n', numLeaves);

    %% 5. Scale calculation 
    if ~isempty(centers)
        coin_diam_px = 2 * coinRadius;
        px_to_mm = coin_diam_mm / coin_diam_px;
        fprintf('Scale factor = %.4f mm/pixel\n', px_to_mm);
    else
        px_to_mm = NaN;
    end

    %% 6. Leaf measurement 
    leafStats  = regionprops(L,'Area','Perimeter','BoundingBox','PixelIdxList');
    R = double(I(:,:,1)); G = double(I(:,:,2)); B = double(I(:,:,3));

    GLI_vals   = zeros(numLeaves,1);
    area_vals  = zeros(numLeaves,1);
    perim_vals = zeros(numLeaves,1);

    for n = 1:numLeaves
        mask_n = (L == n);

        % GLI
        GLI_vals(n) = mean((2*G(mask_n)-R(mask_n)-B(mask_n)) ./ ...
                           (2*G(mask_n)+R(mask_n)+B(mask_n)));

        % Area & perimeter (in mm)
        area_vals(n)  = leafStats(n).Area * px_to_mm^2;
        perim_vals(n) = leafStats(n).Perimeter * px_to_mm;

        % saved cropped leaf
        cropped = I .* uint8(mask_n);
        outName = sprintf('leaf%02d_from_%s.png', n, erase(fname,'.jpg'));
        imwrite(cropped, fullfile(imageFolder, outName));
    end

    %%  7. Ranking 
    [~, rankArea] = sort(area_vals,'descend');
    [~, rankGLI]  = sort(GLI_vals,'descend');
    fprintf('Ranking by area → %s\n', mat2str(rankArea));
    fprintf('Ranking by GLI  → %s\n', mat2str(rankGLI));

    %% 8. Annotation
    RGB_annot = labeloverlay(I,L);
    figure; imshow(RGB_annot);
    title(sprintf('%s – %d Leaves Detected', fname, numLeaves)); hold on;
    for n = 1:numLeaves
        s = leafStats(n);
        text(s.BoundingBox(1)+5, s.BoundingBox(2)-10, ...
             sprintf('Leaf %d | %.0f mm² | GLI %.2f', ...
             n, area_vals(n), GLI_vals(n)), ...
             'Color','yellow','FontSize',9,'FontWeight','bold');
    end
    hold off;

    %% 9. Results
    if numLeaves>0
        T = table(repmat({fname},numLeaves,1), (1:numLeaves)', ...
            area_vals(:), perim_vals(:), GLI_vals(:), ...
            'VariableNames',{'Image','LeafID','Area_mm2','Perimeter_mm','GLI'});
        results = [results; T]; 
    end



end


