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
