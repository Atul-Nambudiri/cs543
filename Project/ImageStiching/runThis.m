% img_path = strcat('images/test_', num2str(img_idx), '.jpg');
im1 = imresize(imread('images/uni1.jpg'), .3);
im2 = imresize(imread('images/uni2.jpg'), .3);
im3 = imresize(imread('images/uni3.jpg'), .3);
im4 = imresize(imread('images/uni4.jpg'), .3);

% pan2 = image_stich(im2, im3);
% [row, col, chan] = size(im1);
% pan2 = imresize(pan2, [row, col]);
% pan1 = image_stich(im1, pan2);

pan1 = image_stich(im1, im2);
[row, col, chan] = size(pan1);
pan2 = image_stich(im3, im4);
pan2 = imresize(pan2, [row, col]);

pan3 = image_stich(pan1(200:700, 1:600, :), pan2(200:700, 1:600, :));

figure(1)
imshow(pan1);
figure(2)
imshow(pan2);