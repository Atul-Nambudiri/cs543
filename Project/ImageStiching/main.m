left = rgb2gray(imresize(imread('images/left.jpg'), .3));
right = rgb2gray(imresize(imread('images/right.jpg'), .3));

left_s = single(left);
right_s = single(right);

[f_left,d_left] = vl_sift(left_s);
[f_right,d_right] = vl_sift(right_s);
[matches, scores] = vl_ubcmatch(d_left, d_right);

% imshow(left);
% perm = randperm(size(f_left,2));
% sel = perm(1:50);
% h1 = vl_plotframe(f_left(:,sel));
% h2 = vl_plotframe(f_left(:,sel));
% set(h1,'color','k','linewidth',3);
% set(h2,'color','y','linewidth',2);
% h3 = vl_plotsiftdescriptor(d_left(:,sel),f_left(:,sel)) ;
% set(h3,'color','g') ;

matches = matches';
r1 = f_left(2, :);
c1 = f_left(1, :);

r2 = f_right(2, :);
c2 = f_right(1, :);

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
best_number_in_threshold = 0;
best_dist = 0;
threshold = 1.1;
best_F = zeros(1);

best_inliers = [];
best_outliers = [];

for t = 1:2000
    set = randperm(n, 8);
    
    inliers = [];
    outliers = [];
    
    points1 = ones(8, 3);
    points2 = ones(8, 3);
    
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
    
    %Normalize this F for future calculations
    norm_F = T2' * F * T1;
    
    number_in_threshold = 0;
    dist_sum = 0;
    
    % Calculate I for each point, normalize it, and then check to see if 
    % its in the threshold
    for i = 1:n
        u = c1_old(matches(i, 1));
        v = r1_old(matches(i, 1));
        I = norm_F' * vertcat(u, v, 1);
        distance = abs(I(1) * u + I(2) * v + I(3))/sqrt(I(1)*I(1) + I(2)*I(2));
        
        u2 = c2_old(matches(i, 2));
        v2 = r2_old(matches(i, 2));
        I2 = norm_F * vertcat(u2, v2, 1);
        distance2 = abs(I2(1) * u2 + I2(2) * v2 + I2(3))/sqrt(I2(1)*I2(1) + I2(2)*I2(2));
        
        if distance < threshold && distance2 < threshold
            number_in_threshold = number_in_threshold + 1;
            dist_sum = dist_sum + distance;
            inliers = [inliers; i];
        else
            outliers = [outliers; i];
        end
    end
    if number_in_threshold >= best_number_in_threshold
        best_F = F;
        best_number_in_threshold = number_in_threshold;
        best_dist = dist_sum;
        best_inliers = inliers;
        best_outliers = outliers;
    end
end

% Unnormalize F
F = T2' * best_F * T1;

inliers1 = [];
inliers1_lines = [];
inliers2 = [];
inliers2_lines = [];
outliers1 = [];

% Calculate I for each inlier
for i = 1:length(best_inliers)
    u = c1_old(matches(best_inliers(i), 1));
    v = r1_old(matches(best_inliers(i), 1));
    I = F' * vertcat(u, v, 1);
    
    u2 = c2_old(matches(best_inliers(i), 2));
    v2 = r2_old(matches(best_inliers(i), 2));
    I2 = F * vertcat(u2, v2, 1);

    inliers1 = [inliers1; horzcat(u, v)];
    inliers2 = [inliers2; horzcat(u2, v2)];
    inliers1_lines = [inliers1_lines; I'];
    inliers2_lines = [inliers2_lines; I2'];
end

% Calculate I for each inlier
for i = 1:length(best_outliers)
    u = c1_old(matches(best_outliers(i), 1));
    v = r1_old(matches(best_outliers(i), 1));
    
    outliers1 = [outliers1; horzcat(u, v)];
end

size(inliers1_lines)

imagesc(left) ; colormap gray ; hold on ; axis image ; axis off ;
plot(outliers1(:, 1), outliers1(:, 2), 'g.');
figure();

[len, x] = size(inliers1);
set = [1:len];
if len > 6
    set = randperm(len, 7);
end

subplot(121);
imagesc(left) ; colormap gray ; hold on ; axis image ; axis off ;
for i = 1:length(set)
    [len, width] = size(left);
    plot(inliers1(set(i), 1), inliers1(set(i), 2), 'r+');
    line = inliers1_lines(set(i), :);
    plot([1 width], [max((-line(3)-line(1)*1)/line(2)) min(len, (-line(3)-line(1)*width)/line(2))], 'g');
end

subplot(122);
imagesc(right) ; colormap gray ; hold on ; axis image ; axis off ;
for v = 1:length(set)
    [len, width] = size(right);
    plot(inliers2(set(v), 1), inliers2(set(v), 2), 'r+');
    line = inliers2_lines(set(v), :);
    plot([1 width], [max(0, (-line(3)-line(1)*1)/line(2)) min(len, (-line(3)-line(1)*width)/line(2))], 'g');
end
hold off;

F = normc(F)
