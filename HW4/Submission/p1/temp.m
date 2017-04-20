% function [cIndMap, time, imgVis] = slic(img, K, compactness)
img = imread('lion.jpg');
K = 25;
compactness = 25;
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
[rx_grad, ry_grad] = imgradientxy(img(:,:,1));
[gx_grad, gy_grad] = imgradientxy(img(:,:,2));
[bx_grad, by_grad] = imgradientxy(img(:,:,3));

[x_size, y_size] = size(rx_grad);
grad = zeros(x_size, y_size);
cIndMap = uint16(zeros(x_size, y_size));
distance = double(zeros(x_size, y_size));
S = uint16(sqrt(x_size * y_size/K));

for i = 1:x_size
    for j = 1:y_size
        x_norm = norm([rx_grad(i,j), gx_grad(i,j), bx_grad(i,j)]);
        y_norm = norm([ry_grad(i,j), gy_grad(i,j), by_grad(i,j)]);
        grad(i,j) = norm([x_norm, y_norm]);
        distance(i, j) = realmax;
    end
end

cluster_centers = [];

for i = 1:S:x_size
    for j = 1:S:y_size
        %Move cluster to min gradient position in 3x3 around the cluster center
        lowX = max([1, i - 1]);
        lowY = max([1, j - 1]);
        highX = min([x_size, i + 1]);
        highY = min([y_size, j + 1]);
        [num, idx] = min(grad(lowX:highX, lowY:highY));
        [y, x] = ind2sub([3 3], idx);
        posX = uint16(x(1)) + lowX - 1;
        posY = uint16(y(1)) + lowY - 1;
        entry = double([posX, posY, img(posX,posY,1), img(posX,posY,2), img(posX,posY,3)]);
        cluster_centers = [cluster_centers; entry];
    end
end

error = 100000000;
while(error > 1)
    [u, v] = meshgrid(1:x_size, 1:y_size);
    for t = 1:length(cluster_centers)
        lowX = max([1, cluster_centers(t, 1) - S]);
        lowY = max([1, cluster_centers(t, 2) - S]);
        highX = min([x_size, cluster_centers(t, 1) + S]);
        highY = min([y_size, cluster_centers(t, 2) + S]);
        for u = lowX:highX
            for v = lowY:highY
                dc = sqrt(double((cluster_centers(t, 3) - double(img(u,v,1)))^2 + (cluster_centers(t, 4) - double(img(u,v,2)))^2 + (cluster_centers(t, 5) - double(img(u,v,3)))^2));
                ds = sqrt(double((cluster_centers(t, 1) - double(u))^2 + (cluster_centers(t, 2) - double(v))^2));
                D = sqrt(dc^2 + (ds/double(S))^2 * double(compactness)^2);
                if D < distance(u, v)
                    distance(u, v) = D;
                    cIndMap(u, v) = t;
                end
            end
        end
    end
    break
    error = 0;
    for t = 1:length(cluster_centers)
        [r, c] = find(cIndMap == t);
        r_sum = 0;
        g_sum = 0;
        b_sum = 0;
        x_sum = 0;
        y_sum = 0;
        for p = 1:length(r)
            r_sum = r_sum + img(r(p),c(p),1);
            g_sum = g_sum + img(r(p),c(p),2);
            b_sum = b_sum + img(r(p),c(p),3);
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
    error = sqrt(error);
end

% Post Processing
for t = 1:length(cluster_centers)
    res = bwconncomp(cIndMap == t);
    if res.NumObjects > 1
        for i = 2:res.NumObjects
            pixels = res.PixelIdxList(i);
            pixels = pixels{1};
            for v = 1:length(pixels)
                [y, x] = ind2sub(size(cIndMap), pixels(v));
                min1 = 10000000000;
                min_cluster = -1;
                for j = 1:length(cluster_centers)
                    dist = sqrt((double(cluster_centers(j, 1)) - double(x))^2 + (double(cluster_centers(j, 2)) - double(y))^2);
                    if dist < min1
                        min1 = dist;
                        min_cluster = j;
                    end
                end
                cIndMap(y, x) = min_cluster;
            end
        end
    end
end

% Post Processing
for t = 1:length(cluster_centers)
    res = bwconncomp(cIndMap == t);
    if res.NumObjects > 1
        for i = 1:res.NumObjects
            pixels = res.PixelIdxList(i);
            pixels = pixels{1};
            
            for v = 1:length(pixels)
                [y, x] = ind2sub(size(cIndMap), pixels(v));
                dist = sqrt((double(cluster_centers(:, 1)) - double(x)).^2 + (double(cluster_centers(:, 2)) - double(y)).^2);
                [m, p] = min(dist);
                cIndMap(y, x) = p(1);
            end
        end
    end
end

for t = 1:length(cluster_centers)
    res = bwperim(cIndMap == t);
    [r, c] = find(res);
    for p = 1:length(r)
        img(r(p), c(p), 1) = 255;
        img(r(p), c(p), 2) = 255;
        img(r(p), c(p), 3) = 255;
    end
end
imgVis = img;
imshow(img);
cIndMap = uint16(cIndMap);
% 
time = toc;

for q = 1:3
    % Post Processing
    for t = 1:length(cluster_centers)
        res = bwconncomp(cIndMap == t);
        if res.NumObjects > 1
            m = regionprops(res,'Centroid');
            for i = 1:res.NumObjects
                pixels = res.PixelIdxList(i);
                pixels = pixels{1};
                [min1, clusters] = min(pdist2(m(i).Centroid, cluster_centers(:, 1:2)));
                cIndMap(pixels) = clusters;
            end
        end
    end
    for t = 1:length(cluster_centers)
        [r, c] = find(cIndMap == t);
        r_sum = 0;
        g_sum = 0;
        b_sum = 0;
        x_sum = 0;
        y_sum = 0;
        for p = 1:length(r)
            r_sum = r_sum + img(r(p),c(p),1);
            g_sum = g_sum + img(r(p),c(p),2);
            b_sum = b_sum + img(r(p),c(p),3);
            x_sum = x_sum + r(p);
            y_sum = y_sum + c(p);
        end
        if length(r) ~= 0
            new_cluster_center = [double(x_sum)/double(length(r)), double(y_sum)/double(length(r)), double(r_sum)/double(length(r)), double(g_sum)/double(length(r)), double(b_sum)/double(length(r))];
        else
            new_cluster_center = cluster_centers(t, :);
        end
        cluster_centers(t, :) = new_cluster_center;
    end
end


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
                [min1, clusters] = min(pdist2(m(i).Centroid, cluster_centers(:, 1:2)));
                cIndMap(pixels) = clusters;
            end
        end
    end
end

