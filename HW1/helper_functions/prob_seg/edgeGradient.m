function bmap=edgeGradient(im)
im = im2double(im);
[mag, theta] = gradientMagnitude(im, 2.5);

canny_edge = edge(rgb2gray(im), 'canny');
bmap = mag .* canny_edge;