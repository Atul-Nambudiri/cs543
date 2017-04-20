load('cat_poly.mat', 'poly');
im = imread('cat.jpg');

k1s = [1, 2, 4, 8];
k2s = [1, 2, 4, 8];
sigmas = [1, 2];
n_bins_list = [8, 16, 32, 64];

best = containers.Map('KeyType','double', 'ValueType','any');

for i = 1:length(k1s)
    for j = 1:length(k2s)
        for k = 1:length(sigmas)
            for l = 1:length(n_bins_list)
                k1 = k1s(i)
                k2 = k2s(j)
                sigma = sigmas(k)
                n_bins = n_bins_list(l)
                [new_labels, foreground_hist] = runGraphCuts(im, poly, k1, k2, sigma, n_bins);
                score = sum(sum(sum(new_labels == 1)));
                best(score) = [k1, k2, sigma, n_bins];
            end
        end
    end
end

best