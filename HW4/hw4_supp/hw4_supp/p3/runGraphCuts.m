function [new_labels, foreground_hist] = runGraphCuts(im, poly, k1, k2, sigma, n_bins)

[m, n, l] = size(im);

mask = poly2mask(poly(:, 1), poly(:, 2), m, n);

[fr, fc] = find(mask == 1);
[br, bc] = find(mask == 0);

labels = ones(m, n);
new_labels = mask;

count = 0;

while ~isequal(labels, new_labels) 
    labels = new_labels;
    [foreground_hist, background_hist] = createHistograms(im, fr, fc, br, bc, n_bins);
    [DataCost, SmoothnessCost, vC, hC] = createCosts(im, k1, k2, sigma, foreground_hist, background_hist, n_bins);
    [gch] = GraphCut('open', DataCost, SmoothnessCost, vC, hC);
    [gch, new_labels] = GraphCut('expand', gch);
    GraphCut('close', gch);
    [fr, fc] = find(new_labels == 0);
    [br, bc] = find(new_labels == 1);
    if count == 60
        break
    end
end
