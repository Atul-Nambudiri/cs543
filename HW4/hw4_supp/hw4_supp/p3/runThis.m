load('cat_poly.mat', 'poly');
im = imread('cat.jpg');

[m, n, z] = size(im);

k1 = 4;
k2 = 8;
sigma = 4;
n_bins = 16;

[new_labels, foreground_hist] = runGraphCuts(im, poly, k1, k2, sigma, n_bins);

intensities = zeros(m, n);
divisor = 256/n_bins;

for i = 1:m
    for j = 1:n
        if new_labels(i, j) == 1
            im(i, j, 1) = 0;
            im(i, j, 2) = 0;
            im(i, j, 3) = 255;
        end
        r_cell = ceil(double(im(i, j, 1) + 1)/divisor);
        g_cell = ceil(double(im(i, j, 2) + 1)/divisor);
        b_cell = ceil(double(im(i, j, 3) + 1)/divisor);
%         intensities(i, j, 1) = foreground_hist(r_cell, g_cell, b_cell) * 255;
%         intensities(i, j, 2) = foreground_hist(r_cell, g_cell, b_cell) * 255;
%         intensities(i, j, 3) = foreground_hist(r_cell, g_cell, b_cell) * 255;
        intensities(i, j) = foreground_hist(r_cell, g_cell, b_cell) * 255;
        if foreground_hist(r_cell, g_cell, b_cell) == .500
            intensities(i, j) = 0;
        end
    end
end

imshow(im);
figure();
imagesc(intensities);