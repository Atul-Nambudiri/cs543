im = imread('hw2_supp/tracking/images/hotel.seq0.png');

[keyXs, keyYs] = getKeypoints(im, 3000000);

length(keyXs)

imshow(im);
hold on;
scatter(keyXs, keyYs);