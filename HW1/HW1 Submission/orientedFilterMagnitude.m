function [mag,theta] = orientedFilterMagnitude(im)
S90 = [[1 2 1]
       [0 0 0]
       [-1 -2 -1]];
S135 = [[2 1 0]
        [1 0 -1]
        [0 -1 -2]];
S0 = [[-1 0 1]
      [-2 0 2]
      [-1 0 1]];
S45 = [[0 1 2]
       [-1 0 1]
       [-2 -1 0]];
    
[x, y, z] = size(im);
image_responses = zeros(x, y, 3, 4);
im = imgaussfilt(im, 2.5);

for i = 1:3
    image_responses(:,:,i,1) = imfilter(im(:,:,i), S0);
    image_responses(:,:,i,2) = imfilter(im(:,:,i), S45);
    image_responses(:,:,i,3) = imfilter(im(:,:,i), S90);
    image_responses(:,:,i,4) = imfilter(im(:,:,i), S135);
end

mag = zeros(x,y);
theta = zeros(x,y);
theta_list = [0 pi/4 pi/2 3*pi/4];

for i = 1:x
    for j = 1:y
        max_mag = -200;
        max_theta = 0;
        for l = 1:4
            filter_norm = norm([image_responses(i,j,1,l), image_responses(i,j,2,l), image_responses(i,j,3,l)]);
            if filter_norm > max_mag
                max_mag = filter_norm;
                max_theta = theta_list(l);
            end
        end
        mag(i, j) = max_mag;
        theta(i, j) = max_theta;
    end
end
