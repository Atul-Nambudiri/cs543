function bmap= edgeOrientedFilters(im)
im = im2double(im);
[mag, theta] = orientedFilterMagnitude(im);
canny_edge = edge(rgb2gray(im), 'canny');
bmap = mag .* canny_edge;