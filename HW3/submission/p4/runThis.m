load tracked_points.mat Xs Ys

[m, n] = size(Xs);

D = zeros(2*m, n);

for i = 1:m
   for j = 1:n
       D(i, j) = Xs(i, j);
       D(i + m, j) = Ys(i, j);
   end
   
   mn1 = mean(D(i, :));
   mn2 = mean(D(i + m, :));
   
   for j = 1:n
       D(i, j) = D(i, j) - mn1;
       D(i + m, j) = D(i + m, j) - mn2;
   end
end

[U, S, V] = svd(D);

U3 = U(:, 1:3);
V3 = V(:, 1:3);
S3 = S(1:3, 1:3);

Mt = U3 * sqrtm(S3);
St = sqrtm(S3) * V3';

[x, y] = size(Mt);

A = zeros(m*3, 9);
Y = zeros(m*3, 1);

k1 = ones(m, 1);
k2 = ones(m, 1);
k3 = ones(m, 1);

for i = 1:m
    ti = Mt(i, 1);
    ui = Mt(i, 2);
    vi = Mt(i, 3);
    tj = Mt(i + 51, 1);
    uj = Mt(i + 51, 2);
    vj = Mt(i + 51, 3);
    A(3*(i-1) + 1, :) =  [ti * ti, ti * ui, ti * vi, ui * ti, ui * ui, ui * vi, vi * ti, vi * ui, vi * vi];
    A(3*(i-1) + 2, :) =  [tj * tj, tj * uj, tj * vj, uj * tj, uj * uj, uj * vj, vj * tj, vj * uj, vj * vj];
    A(3*(i-1) + 3, :) =  [ti * tj, ti * uj, ti * vj, ui * tj, ui * uj, ui * vj, vi * tj, vi * uj, vi * vj];
    Y(3*(i-1) + 1, :) = 1;
    Y(3*(i-1) + 2, :) = 1;
    Y(3*(i-1) + 3, :) = 0;
    
    %Get the camera position
    k = real(cross([ti; ui; vi], [tj, uj, vj]));
    k = k/norm(k);
    k
    
    k1(i, 1) = k(1);
    k2(i, 1) = k(2);
    k3(i, 1) = k(3);
end

L = A \ Y;
L = reshape(L, [3 3])';

C = chol(L, 'lower');

S = C\St;

size(S);

scatter3(S(1, :), S(2, :), S(3, :), 5);
figure();

plot(k1);
figure();
plot(k2);
figure();
plot(k3);
