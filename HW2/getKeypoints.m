function [keyXs, keyYs] = getKeypoints(im, tau)

alpha = .01;
[Ix, Iy] = imgradientxy(im);

gIx2 = imgaussfilt(Ix.^2);
gIy2 = imgaussfilt(Iy.^2);
gIxy = imgaussfilt(Ix.*Iy);

har = gIx2 .* gIy2 - (gIxy).^2 - alpha * (gIx2 + gIy2).^2;

har(har < tau) = 0;

max_in_region = imdilate(har, true(5));
har(har ~= max_in_region) = 0;

[keyYs, keyXs] = find(har);

