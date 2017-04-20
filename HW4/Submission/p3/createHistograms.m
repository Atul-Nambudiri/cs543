function [foreground_hist, background_hist] = createHistograms(img, fr, fc, br, bc, n_bins)

foreground_hist = double(zeros(n_bins, n_bins, n_bins));
background_hist = double(zeros(n_bins, n_bins, n_bins));

divisor = 256/n_bins;

for p = 1:length(fr)
    r_cell = ceil(double(img(fr(p), fc(p), 1) + 1)/divisor);
    g_cell = ceil(double(img(fr(p), fc(p), 2) + 1)/divisor);
    b_cell = ceil(double(img(fr(p), fc(p), 3) + 1)/divisor);
    foreground_hist(r_cell, g_cell, b_cell) = foreground_hist(r_cell, g_cell, b_cell) + 1;
end

for p = 1:length(br)
    r_cell = ceil(double(img(br(p), bc(p), 1) + 1)/divisor);
    g_cell = ceil(double(img(br(p), bc(p), 2) + 1)/divisor);
    b_cell = ceil(double(img(br(p), bc(p), 3) + 1)/divisor);
    
    background_hist(r_cell, g_cell, b_cell) = background_hist(r_cell, g_cell, b_cell) + 1;
end


foreground_hist = foreground_hist + .001;
background_hist = background_hist + .001;


for i = 1:n_bins
    for j = 1:n_bins
        for k = 1:n_bins
            s = foreground_hist(i, j, k) + background_hist(i, j, k);
            foreground_hist(i, j, k) = foreground_hist(i, j, k)/s;
            background_hist(i, j, k) = background_hist(i, j, k)/s;
        end
    end
end

% foreground_hist = foreground_hist/sum(sum(sum(foreground_hist)));
% background_hist = background_hist/sum(sum(sum(background_hist)));

