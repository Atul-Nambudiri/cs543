function bmap=newTest(im)
im = im2double(im);
im2 = rgb2hsv(im);
[mag, theta] = orientedFilterMagnitude(im2);

canny_edge = edge(rgb2gray(im), 'canny');
bmap = mag .* canny_edge;