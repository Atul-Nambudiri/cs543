load prob3.mat r1 c1 r2 c2 matches

im1 = imread('chapel00.png');
im2 = imread('chapel01.png');

h = 1;

r1_old = r1;
c1_old = c1;
r2_old = r2;
c2_old = c2;

mean1Y = mean(r1);
mean1X = mean(c1);
mean2Y = mean(r2);
mean2X = mean(c2);

std1Y = std(r1);
std1X = std(c1);
std2Y = std(r2);
std2X = std(c2);

t1 = [1 0 -mean1X; 0 1 -mean1Y; 0 0 1];
t2 = [1/std1X 0 0; 0 1/std1Y 0; 0 0 1];
t3 = [1/std2X 0 0; 0 1/std2Y 0; 0 0 1];
t4 = [1 0 -mean2X; 0 1 -mean2Y; 0 0 1];

%Create the normalization matrices to normalize the coordinates
T1 = t2 * t1;
T2 = t3 * t4;

%Normalize the coordinates
for r = 1:length(c1)
    n_point = T1 * vertcat(c1(r), r1(r), 1);
    c1(r) = n_point(1);
    r1(r) = n_point(2);
end

for c = 1:length(c2)
    n_point = T2 * vertcat(c2(c), r2(c), 1);
    c2(c) = n_point(1);
    r2(c) = n_point(2);
end

[n, k] = size(matches);

set = randperm(n, 8);
set = [5, 30, 70, 90, 100, 150, 200, 250];
    
points1 = ones(8, 3);
points2 = ones(8, 3);
threshold = .5;

A = zeros(8, 9);

for i = 1:8
    pos1 = matches(set(i), 1);
    pos2 = matches(set(i), 2);
    points1(i, :) = [c1(pos1), r1(pos1), 1];
    points2(i, :) = [c2(pos2), r2(pos2), 1];

    u1 = points1(i, 1);
    v1 = points1(i, 2);
    u2 = points2(i, 1);
    v2 = points2(i, 2);

    A(i, :) = [u1 * u2, u1 * v2, u1, v1 * u2, v1 * v2, v1, u2, v2, 1];
end

[U, S, V] = svd(A);
f = V(:, end);
F = reshape(f, [3 3])';

[U, S, V] = svd(F);
S(3,3) = 0;
F = U*S*V';

% Unnormalize F
F = T2' * F * T1;


inliers1 = [];
inliers1_lines = [];
inliers2 = [];
inliers2_lines = [];
outliers = [];

% Calculate I for each point, normalize it, and then check to see if 
% its in the threshold
for i = 1:n
    u = c1_old(matches(i, 1));
    v = r1_old(matches(i, 1));
    I = F' * vertcat(u, v, 1);
    
    distance = (I(1) * u + I(2) * v + I(3))/sqrt(I(1) ^ 2 + I(2) ^ 2);
    if distance < threshold
        u2 = c2_old(matches(i, 2));
        v2 = r2_old(matches(i, 2));
        inliers1 = [inliers1; horzcat(u, v)];
        I2 = F * vertcat(u2, v2, 1);
        inliers2 = [inliers2; horzcat(u2, v2)];
        inliers1_lines = [inliers1_lines; I'];
        inliers2_lines = [inliers2_lines; I2'];
    else
        outliers = [outliers; horzcat(u, v)];
    end
end

size(inliers1_lines)

% imagesc(im1) ; colormap gray ; hold on ; axis image ; axis off ;
% plot(outliers(:, 2), outliers(:, 1), 'g.');
figure();

[len, x] = size(inliers1);
set = randperm(len, 7);

imagesc(im1) ; colormap gray ; hold on ; axis image ; axis off ;
for i = 1:length(set)
    [len, width] = size(im1);
    plot(inliers1(set(i), 1), inliers1(set(i), 2), 'r+');
    line = inliers1_lines(set(i), :);
    plot([1 width], [(-line(3)-line(1)*1)/line(2) (-line(3)-line(1)*width)/line(2)]);
end

figure();

imagesc(im2) ; colormap gray ; hold on ; axis image ; axis off ;
for v = 1:length(set)
    [len, width] = size(im2);
    plot(inliers2(set(v), 1), inliers2(set(v), 2), 'r+');
    line = inliers2_lines(set(v), :);
    plot([1 width], [(-line(3)-line(1)*1)/line(2) (-line(3)-line(1)*width)/line(2)]);
end


%plot([(1*line(2)+line(3))/(-line(1)) (len*line(2)+line(3))/(-line(1))], [1 len]);
