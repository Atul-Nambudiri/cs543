function A = alignShape(im1, im2)

tic

[p1Ys, p1Xs] = find(im1>0);
[p2Ys, p2Xs] = find(im2>0);

meanp1X = mean(p1Xs);
meanp1Y = mean(p1Ys);
meanp2X = mean(p2Xs);
meanp2Y = mean(p2Ys);

stdp1X = std(p1Xs);
stdp1Y = std(p1Ys);
stdp2X = std(p2Xs);
stdp2Y = std(p2Ys);

t1 = [1 0 -meanp1X; 0 1 -meanp1Y; 0 0 1];
t2 = [1/stdp1X 0 0; 0 1/stdp1Y 0; 0 0 1];
t3 = [stdp2X 0 0; 0 stdp2Y 0; 0 0 1];
t4 = [1 0 meanp2X; 0 1 meanp2Y; 0 0 1];

for i = 1:length(p1Xs)
   point = [p1Xs(i); p1Ys(i); 1];
   transformed_point = t4 * t3 * t2 * t1 * point;
   p1Xs(i) = transformed_point(1);
   p1Ys(i) = transformed_point(2);
end

points1 = horzcat(p1Xs, p1Ys);
points2 = horzcat(p2Xs, p2Ys);

newPoints = zeros(size(points1));

mat = [points1(1,1) points1(1,2) 1 0 0 0; 0 0 0 points1(1,1) points1(1,2) 1];

for t = 1:35
    indices = dsearchn(points2, points1);
    mat = [points1(1,1) points1(1,2) 1 0 0 0; 0 0 0 points1(1,1) points1(1,2) 1];
    pprimes = [points2(indices(1), 1); points2(indices(1), 1)];
    for i = 2:length(indices)
        n_mat = [points1(i,1) points1(i,2) 1 0 0 0; 0 0 0 points1(i,1) points1(i,2) 1];
        n_pprimes = [points2(indices(i), 1); points2(indices(i), 2)];
        mat = vertcat(mat, n_mat);
        pprimes = vertcat(pprimes, n_pprimes);
    end

    A_vals = mat\pprimes;
    
    A = [A_vals(1) A_vals(2) A_vals(3); A_vals(4) A_vals(5) A_vals(6)];
    
    for i = 1:length(indices)
        newPoints(i, :) = A * vertcat(transpose(points1(i, :)), 1);
    end
    
    points1 = newPoints;
end

out = zeros(size(im2));

for i = 1:length(newPoints)
   out(round(newPoints(i, 2)), round(newPoints(i, 1))) = 1;
end

toc

error = evalAlignment(out, im2);
dis = displayAlignment(im1, im2, out, true);

error
imshow(dis);



