function [mag,theta] = orientedFilterMagnitude(im)
% filterBank = makeLMfilters;
% [x, y, z] = size(im);
% image_responses = zeros(x, y, 3, 24);
% 
% im = im2double(im);
% 
% for i = 1:24
%     for j = 1:3
%         image_responses(:,:,j, i) = imfilter(im(:,:,j), filterBank(:,:,i));
%     end
% end
% 
% %Method oriented:	overall F-score = 0.565		average F-score = 0.591
% 
% mag = zeros(x,y);
% theta = zeros(x,y);
% theta_list = [0 pi/12 2*pi/12 3*pi/12 4*pi/12 5*pi/12 6*pi/12 7*pi/12 8*pi/12 9*pi/12 10*pi/12 11*pi/12];
% 
% for i = 1:x
%     for j = 1:y
%         max_mag = -5000;
%         max_theta = 0;
%         for k = 1:24
%             filter_norm = norm([image_responses(i,j,1,k), image_responses(i,j,2,k), image_responses(i,j,3,k)]);
%             if filter_norm > max_mag
%                 max_mag = filter_norm;
%                 res = mod(k, 12);
%                 if res == 0
%                     res = 12;
%                 end
%                 max_theta = theta_list(res);
%             end
%         end
%         max_mag = -200;
%         for l = 1:3
%             t = zeros(54);
%             for m = 1:54
%                 t(m) = image_responses(i,j,l,m);
%             end
%             channel_norm = norm(t);
%             if channel_norm > max_mag
%                 max_mag = channel_norm;
%             end
%         end
%         mag(i, j) = max_mag;
%         theta(i, j) = max_theta;
%     end
% end

% S0 = [[1 2 1]
%       [0 0 0]
%       [-1 -2 -1]];
% S135 = [[2 1 0]
%        [1 0 -1]
%        [0 -1 -2]];
% S90 = [[-1 0 1]
%        [-2 0 2]
%        [-1 0 1]];
% S45 = [[0 1 2]
%         [-1 0 1]
%         [-2 -1 0]];
%     
% [x, y, z] = size(im);
% image_responses = zeros(x, y, 3, 4);
% im = imgaussfilt(im, 2.5);
% 
% for i = 1:3
%     image_responses(:,:,i,1) = imfilter(im(:,:,i), S0);
%     image_responses(:,:,i,2) = imfilter(im(:,:,i), S45);
%     image_responses(:,:,i,3) = imfilter(im(:,:,i), S90);
%     image_responses(:,:,i,4) = imfilter(im(:,:,i), S135);
% end
% 
% overall F-score = 0.555		average F-score = 0.581
%
% mag = zeros(x,y);
% theta = zeros(x,y);
% theta_list = [0 pi/4 pi/2 3*pi/4];
% 
% for i = 1:x
%     for j = 1:y
%         max_mag = -200;
%         max_theta = 0;
%         for l = 1:4
%             filter_norm = norm([image_responses(i,j,1,l), image_responses(i,j,2,l), image_responses(i,j,3,l)]);
%             if filter_norm > max_mag
%                 max_mag = filter_norm;
%                 max_theta = theta_list(l);
%             end
%         end
%         mag(i, j) = max_mag;
%         theta(i, j) = max_theta;
%     end
% end

% im = im2double(im);
% im = imgaussfilt(im, 2.5);
% filterbank = gabor([3], [0 15 30 45 60 75 90 105 120 135 150 165 180]);
% [magr, phaser] = imgaborfilt(im(:, :, 1), filterbank);
% [magg, phaseg] = imgaborfilt(im(:, :, 2), filterbank);
% [magb, phaseb] = imgaborfilt(im(:, :, 3), filterbank);
% 
% [x, y, z] = size(im);
% [t, v, filters_length] = size(magr);
% image_responses = zeros(x, y, 3, filters_length);
% image_thetas = zeros(x, y, 3, filters_length);
% 
% 
% for i = 1:filters_length
%     image_responses(:,:,1,i) = magr(:,:,i);
%     image_responses(:,:,2,i) = magg(:,:,i);
%     image_responses(:,:,3,i) = magb(:,:,i);
%     image_thetas(:,:,1,i) = phaser(:,:,i);
%     image_thetas(:,:,2,i) = phaseg(:,:,i);
%     image_thetas(:,:,3,i) = phaseb(:,:,i);
% end
% 
% mag = zeros(x,y);
% theta = zeros(x,y);
% 
% for i = 1:x
%     for j = 1:y
%         max_mag = -200;
%         max_theta = 0;
%         for l = 1:filters_length
%             filter_norm = norm([image_responses(i,j,1,l), image_responses(i,j,2,l), image_responses(i,j,3,l)]);
%             if filter_norm > max_mag
%                 max_mag = filter_norm;
%                 max_theta = image_thetas(i,j,1,l);
%             end
%         end
%         max_mag = -200;
%         for l = 1:3
%             t = zeros(filters_length);
%             for m = 1:filters_length
%                 t(m) = image_responses(i,j,l,m);
%             end
%             channel_norm = norm(t);
%             if channel_norm > max_mag
%                 max_mag = channel_norm;
%             end
%         end
%         mag(i, j) = max_mag;
%         theta(i, j) = max_theta;
%     end
% end

% S90 = [[1 2 1]
%        [0 0 0]
%        [-1 -2 -1]];
% S135 = [[2 1 0]
%         [1 0 -1]
%         [0 -1 -2]];
% S0 = [[-1 0 1]
%       [-2 0 2]
%       [-1 0 1]];
% S45 = [[0 1 2]
%        [-1 0 1]
%        [-2 -1 0]];
%     
% [x, y, z] = size(im);
% image_responses = zeros(x, y, 3, 4);
% im = im2double(im);
% im = imgaussfilt(im, 2.5);
% 
% for i = 1:3
%     image_responses(:,:,i,1) = imfilter(im(:,:,i), S0);
%     image_responses(:,:,i,2) = imfilter(im(:,:,i), S45);
%     image_responses(:,:,i,3) = imfilter(im(:,:,i), S90);
%     image_responses(:,:,i,4) = imfilter(im(:,:,i), S135);
% end
% 
% % overall F-score = 0.565		average F-score = 0.588
% 
% mag = zeros(x,y);
% theta = zeros(x,y);
% theta_list = [0 pi/4 pi/2 3*pi/4];
% 
% for i = 1:x
%     for j = 1:y
%         max_mag = -200;
%         max_theta = 0;
%         for l = 1:4
%             filter_norm = norm([image_responses(i,j,1,l), image_responses(i,j,2,l), image_responses(i,j,3,l)]);
%             if filter_norm > max_mag
%                 max_mag = filter_norm;
%                 max_theta = theta_list(l);
%             end
%         end
%         max_mag = -200;
%         for l = 1:3
%             channel_norm = norm([image_responses(i,j,l,1), image_responses(i,j,l,2), image_responses(i,j,l,3), image_responses(i,j,l,4)]);
%             if channel_norm > max_mag
%                 max_mag = channel_norm;
%             end
%         end
%         mag(i, j) = max_mag;
%         theta(i, j) = max_theta;
%     end
% end

% filterBank = makeLMfilters;
% [x, y, z] = size(im);
% image_responses = zeros(x, y, 24);
% im = im2double(im);
% im = rgb2gray(im);
% 
% for i = 1:24
%     image_responses(:,:, i) = imfilter(im, filterBank(:,:,i));
% end
% 
% % Method oriented:	overall F-score = 0.565		average F-score = 0.591
% 
% mag = zeros(x,y);
% theta = zeros(x,y);
% theta_list = [0 pi/12 2*pi/12 3*pi/12 4*pi/12 5*pi/12 6*pi/12 7*pi/12 8*pi/12 9*pi/12 10*pi/12 11*pi/12];
% 
% for i = 1:x
%     for j = 1:y
%         max_mag = -5000;
%         max_theta = 0;
%         for k = 1:24
%             if image_responses(i, j, k) > max_mag
%                 max_mag = image_responses(i, j, k);
%                 res = mod(k, 12);
%                 if res == 0
%                     res = 12;
%                 end
%                 max_theta = theta_list(res);
%             end
%         end
%         mag(i, j) = max_mag;
%         theta(i, j) = max_theta;
%     end
% end

% im = im2double(im);
% im = imgaussfilt(im, 2.5);
% im = rgb2gray(im);
% filterbank = gabor([2], [0 15 30 45 60 75 90 105 120 135 150 165 180]);
% [image_responses, image_thetas] = imgaborfilt(im, filterbank);
% 
% [x, y, z] = size(im);
% [t, v, filters_length] = size(image_responses);
% 
% mag = zeros(x,y);
% theta = zeros(x,y);
% 
% for i = 1:x
%     for j = 1:y
%         max_mag = -200;
%         max_theta = 0;
%         for l = 1:filters_length
%             if image_responses(i,j,l) > max_mag
%                 max_mag = image_responses(i,j,l);
%                 max_theta = image_thetas(i,j,l);
%             end
%         end
%         mag(i, j) = max_mag;
%         theta(i, j) = max_theta;
%     end
% end

% S90 = [[1 2 1]
%        [0 0 0]
%        [-1 -2 -1]];
% S135 = [[2 1 0]
%         [1 0 -1]
%         [0 -1 -2]];
% S0 = [[-1 0 1]
%       [-2 0 2]
%       [-1 0 1]];
% S45 = [[0 1 2]
%        [-1 0 1]
%        [-2 -1 0]];
%     
% [x, y, z] = size(im);
% image_responses = zeros(x, y, 4);
% im = im2double(im);
% im = imgaussfilt(im, 2.5);
% im = rgb2gray(im);
% 
% image_responses(:,:,1) = imfilter(im, S0);
% image_responses(:,:,2) = imfilter(im, S45);
% image_responses(:,:,3) = imfilter(im, S90);
% image_responses(:,:,4) = imfilter(im, S135);
% 
% % overall F-score = 0.565		average F-score = 0.588
% 
% mag = zeros(x,y);
% theta = zeros(x,y);
% theta_list = [0 pi/4 pi/2 3*pi/4];
% 
% for i = 1:x
%     for j = 1:y
%         max_mag = -200;
%         max_theta = 0;
%         for l = 1:4
%             filter_norm = image_responses(i,j,l);
%             if filter_norm > max_mag
%                 max_mag = filter_norm;
%                 max_theta = theta_list(l);
%             end
%         end
%         mag(i, j) = max_mag;
%         theta(i, j) = max_theta;
%     end
% end


filterBank = makeLMfilters;
[x, y, z] = size(im);
image_responses = zeros(x, y, 3, 36);
image_gray = zeros(x, y, 36);

im = im2double(im);

for i = 1:36
    for j = 1:3
        image_responses(:,:,j, i) = imfilter(im(:,:,j), filterBank(:,:,i));
    end
    image = cat(3, image_responses(:,:,1, i), image_responses(:,:,2, i), image_responses(:,:,3, i)); 
    image_gray(:, :, i) = rgb2gray(image);
end

mag = zeros(x,y);
theta = zeros(x,y);
theta_list = [0 pi/12 2*pi/12 3*pi/12 4*pi/12 5*pi/12 6*pi/12 7*pi/12 8*pi/12 9*pi/12 10*pi/12 11*pi/12];

for i = 1:x
    for j = 1:y
        max_mag = -5000;
        max_theta = 0;
        for k = 1:36
            filter_norm = image_gray(i, j, k);
            if filter_norm > max_mag
                max_mag = filter_norm;
                res = mod(k, 12);
                if res == 0
                    res = 12;
                end
                max_theta = theta_list(res);
            end
        end
        mag(i, j) = max_mag;
        theta(i, j) = max_theta;
    end
end
