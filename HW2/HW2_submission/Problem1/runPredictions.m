base = 'hw2_supp/tracking/images/hotel.seq';
im = imread(strcat(base, '0.png'));

[keyXs, keyYs] = getKeypoints(im, 3000000);

size(keyXs)

im = im2double(im);

imshow(im);
hold on;
scatter(keyXs, keyYs);

x_vecs = zeros(51, length(keyXs));
y_vecs = zeros(51, length(keyYs));


x_vecs(1, :) = keyXs;
y_vecs(1, :) = keyYs;

prev_image = im;
for i = 1:50
    i
    cur_image = imread(strcat(strcat(base, int2str(i)), '.png'));
    cur_image = im2double(cur_image);
    [newXs, newYs] = predictTranslationAll(x_vecs(i, :), y_vecs(i, :), prev_image, cur_image);
    x_vecs(i+1, :) = newXs;
    y_vecs(i+1, :) = newYs;
    prev_image = cur_image;
end

[r, c] = size(x_vecs);

oobXs = [];
oobYs = [];

non_neg_indices = find(x_vecs(51, :) ~= -1);
[t, k] = size(non_neg_indices);
p = randperm(k,20);

pointsX = [];
pointsY = [];

for i = 1:51
    for j = 1:length(p)
        pointsX = [pointsX x_vecs(i, p(j))]; 
        pointsY = [pointsY y_vecs(i, p(j))]; 
    end
end

figure();
imshow(im);
hold on;
scatter(pointsX, pointsY, 10, 'filled');

for i = 1:c
    if x_vecs(51, i) == -1
        oobXs = [oobXs keyXs(i)];
        oobYs = [oobYs keyYs(i)];
    end
end

oobXs

figure();
imshow(im);
hold on;
scatter(oobXs, oobYs);
