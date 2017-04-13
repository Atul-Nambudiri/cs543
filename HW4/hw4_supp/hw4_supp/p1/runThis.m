img = imread('BSR/BSDS500/data/images/test/28083.jpg');
% img = imread('house2.jpg');
K = 25;
compactness = 25;

slic(img, K, compactness);