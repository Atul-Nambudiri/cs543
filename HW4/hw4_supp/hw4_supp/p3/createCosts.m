function [datacost, smoothnesscost, vc, hc] = createCosts(img, k1, k2, sigma, foreground_hist, background_hist, n_bins)

[x, y, t] = size(img);

datacost = double(zeros(x, y, 2));
smoothnesscost = zeros(2, 2);
smoothnesscost(1, 2) = 1;
smoothnesscost(2, 1) = 1;
vc = double(zeros(x, y));
hc = double(zeros(x, y));

divisor = 256/n_bins;

for i = 1:x
    for j = 1:y
        r_cell = ceil(double(img(i, j, 1) + 1)/divisor);
        g_cell = ceil(double(img(i, j, 2) + 1)/divisor);
        b_cell = ceil(double(img(i, j, 3) + 1)/divisor);
        
        fp = foreground_hist(r_cell, g_cell, b_cell);
        bp = background_hist(r_cell, g_cell, b_cell);
        datacost(i, j, 1) = -(log(fp) - log(bp));
        if i < x
            vc(i, j) = k1 + k2*exp(-sum((img(i, j) - img(i + 1, j)).^2)/(2*sigma^2));
        end
        if j < y
            vc(i, j) = k1 + k2*exp(-sum((img(i, j) - img(i,j+1)).^2)/(2*sigma^2));
        end
    end
end
