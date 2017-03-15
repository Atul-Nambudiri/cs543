function [mag, theta] = gradientMagnitude(im, sigma)

filtered = imgaussfilt(im, sigma);

[rx_grad, ry_grad] = imgradientxy(filtered(:,:,1));
[gx_grad, gy_grad] = imgradientxy(filtered(:,:,2));
[bx_grad, by_grad] = imgradientxy(filtered(:,:,3));

[x_size, y_size] = size(rx_grad);
mag = zeros(x_size, y_size);
theta = zeros(x_size, y_size);


for i = 1:x_size
    for j = 1:y_size
        x_norm = norm([rx_grad(i,j), gx_grad(i,j), bx_grad(i,j)]);
        y_norm = norm([ry_grad(i,j), gy_grad(i,j), by_grad(i,j)]);
        x_a = max([rx_grad(i,j), gx_grad(i,j), bx_grad(i,j)]);
        y_a = max([ry_grad(i,j), gy_grad(i,j), by_grad(i,j)]);
        mag(i,j) = norm([x_norm, y_norm]);
        theta(i,j) =  atan2(-y_a, x_a);
    end
end