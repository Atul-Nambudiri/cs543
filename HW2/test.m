base = 'hw2_supp/tracking/images/hotel.seq';
im0 = im2double(imread(strcat(base, '0.png')));
im1 = im2double(imread(strcat(base, '1.png')));

[Ix, Iy] = imgradientxy(im0);
[newX, newY] = predictTranslation(379, 367, Ix, Iy, im0, im1);

newX
newY