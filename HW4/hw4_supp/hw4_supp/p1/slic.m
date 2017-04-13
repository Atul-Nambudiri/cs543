function [cIndMap, time, imgVis] = slic(img, K, compactness)
%% Implementation of Simple Linear Iterative Clustering (SLIC)
%
% Input:
%   - img: input color image
%   - K:   number of clusters
%   - compactness: the weighting for compactness
% Output: 
%   - cIndMap: a map of type uint16 storing the cluster memberships
%   - time:    the time required for the computation
%   - imgVis:  the input image overlaid with the segmentation

tic;
% Put your SLIC implementation here

img = im2double(img);
img = rgb2lab(img);

gray = rgb2gray(img);
[grad, dir] = imgradient(gray);

[x_size, y_size] = size(grad);
cIndMap = uint16(zeros(x_size, y_size));
distance = double(zeros(x_size, y_size));
distance(:, :) = double(realmax);
S = uint16(sqrt((x_size * y_size)/K));

cluster_centers = [];

error_map = double(zeros(x_size, y_size));

for i = S/2:S:x_size
    for j = S/2:S:y_size
        %Move cluster to min gradient position in 3x3 around the cluster center
        lowX = max([1, i - 1]);
        lowY = max([1, j - 1]);
        highX = min([x_size, i + 1]);
        highY = min([y_size, j + 1]);
        [num, idx] = min(grad(lowX:highX, lowY:highY));
        [y, x] = ind2sub([highX - lowX highY - lowY], idx);
        posX = uint16(x(1)) + lowX - 1;
        posY = uint16(y(1)) + lowY - 1;
        entry = double([posX, posY, img(posX,posY,1), img(posX,posY,2), img(posX,posY,3)]);
        cluster_centers = [cluster_centers; entry];
    end
end

error = 100000000;
[u, v] = meshgrid(1:x_size, 1:y_size);
u = u.';
v = v.';
count = 0;
while(error > .1)
    for t = 1:length(cluster_centers)
        lowX = max([1, cluster_centers(t, 1) - S]);
        lowY = max([1, cluster_centers(t, 2) - S]);
        highX = min([x_size, cluster_centers(t, 1) + S]);
        highY = min([y_size, cluster_centers(t, 2) + S]);
        r_sec = double(img(lowX:highX, lowY:highY, 1));
        g_sec = double(img(lowX:highX, lowY:highY, 2));
        b_sec = double(img(lowX:highX, lowY:highY, 3));
        u_sec = double(u(lowX:highX, lowY:highY));
        v_sec = double(v(lowX:highX, lowY:highY));
        
        dc = sqrt(double(cluster_centers(t, 3) - r_sec).^2 + (cluster_centers(t, 4) - g_sec).^2 + (cluster_centers(t, 5) - b_sec).^2);
        ds = sqrt(double((cluster_centers(t, 1) - double(u_sec)).^2 + (cluster_centers(t, 2) - double(v_sec)).^2));

        D = sqrt(dc.^2 + (ds/double(S)).^2 * double(compactness)^2);
        
        for i = lowX:highX
            for j = lowY:highY
                if D(i - lowX + 1, j -lowY + 1) < distance(i, j)
                    distance(i, j) = D(i-lowX + 1, j -lowY + 1);
                    cIndMap(i, j) = t;
                end
            end
        end
    end
    error = 0;
    for t = 1:length(cluster_centers)
        [r, c] = find(cIndMap == t);
        r_sum = 0.0;
        g_sum = 0.0;
        b_sum = 0.0;
        x_sum = 0.0;
        y_sum = 0.0;
        for p = 1:length(r)
            r_sum = r_sum + double(img(r(p),c(p),1));
            g_sum = g_sum + double(img(r(p),c(p),2));
            b_sum = b_sum + double(img(r(p),c(p),3));
            x_sum = x_sum + r(p);
            y_sum = y_sum + c(p);
        end
        if length(r) ~= 0
            new_cluster_center = [double(x_sum)/double(length(r)), double(y_sum)/double(length(r)), double(r_sum)/double(length(r)), double(g_sum)/double(length(r)), double(b_sum)/double(length(r))];
        else
            new_cluster_center = cluster_centers(t, :);
        end
        diff = double(new_cluster_center) - double(cluster_centers(t, :));
        diff = diff.^2;
        error = error + sum(diff);
        cluster_centers(t, :) = new_cluster_center;
    end
    if count == 1
        figure(1);
        imagesc(distance);
        colormap jet
    end
    count = count + 1;
    error = sqrt(error);
end

figure(2);
imagesc(distance);
colormap jet


% Post Processing
for t = 1:length(cluster_centers)
    res = bwconncomp(cIndMap == t);
    if res.NumObjects > 1
        m = regionprops(res,'Centroid');
        numPixels = cellfun(@numel,res.PixelIdxList);
        [biggest,idx] = max(numPixels);
        for i = 1:res.NumObjects
            if i ~= idx(1)
                pixels = res.PixelIdxList(i);
                pixels = pixels{1};
                for v = 1:length(pixels)
                    [x, y] = ind2sub(size(cIndMap), pixels(v));
                    if x ~= 1
                        cIndMap(x, y) = cIndMap(x - 1, y);
                    else
                        cIndMap(x, y) = cIndMap(x + 1, y);
                    end
                end
            end
        end
    end
end

img = lab2rgb(img);

for t = 1:length(cluster_centers)
    res = bwperim(cIndMap == t);
    [r, c] = find(res);
    for p = 1:length(r)
        img(r(p), c(p), 1) = 0;
        img(r(p), c(p), 2) = 0;
        img(r(p), c(p), 3) = 0;
    end
end
imgVis = img;
cIndMap = uint16(cIndMap);
figure(3);
imshow(imgVis);

%
time = toc;

