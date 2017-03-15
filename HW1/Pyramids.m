image = imread('parks.jpg');
image_double = im2double(image);
grayscale = rgb2gray(image_double);

level = 5;
gaussian = cell(level);
laplacian = cell(level);

%Create the Pyramids
for i = 1:level
    if i == 1
        gaussian{i} = grayscale;
    else
        cur_gaussian = imgaussfilt(gaussian{i - 1});
        sz = size(cur_gaussian);
        gaussian{i} = imresize(cur_gaussian, sz/2);
        temp = imgaussfilt(imresize(gaussian{i}, sz));
        laplacian{i - 1} = gaussian{i - 1} - temp;
    end
end

% Create a plot of the Pyramids
ha = tight_subplot(2,5,[.01 .03],[.1 .01],[.01 .01]);
for i = 1:level
    axes(ha(i));
    imshow(gaussian{i});
end

for i = 1:level
    colormap('gray');
    if i ~= level
        axes(ha(i + level));
        imagesc(laplacian{i});
        axis off;
    else
        axes(ha(10)); 
        axis off;
    end
end

set(ha(1:9),'XTickLabel',''); set(ha,'YTickLabel','')


% Create a plot of the FFTs of the Pyramids
ha2 = tight_subplot(2,5,[.01 .03],[.1 .01],[.01 .01]);
for i = 1:level
    axes(ha2(i));
    fourier = fft2(gaussian{i});
    fourier = fftshift(fourier); 
    fourier = abs(fourier); 
    fourier = log(fourier); 
    minv = sv(1); maxv = sv(end);
    minv = sv(round(0.005*numel(sv)));  %maxv = sv(round(0.999*numel(sv)));
    hold off, imagesc(fourier, [minv maxv]), axis off, colormap jet, axis image
    colorbar
end

for i = 1:level
    if i ~= level
        axes(ha2(i + level));
        fourier = fft2(gaussian{i});
        fourier = fftshift(fourier); 
        fourier = abs(fourier); 
        fourier = log(fourier); 
        sv = sort(fourier(:));  
        minv = sv(1); maxv = sv(end);
        minv = sv(round(0.005*numel(sv)));  %maxv = sv(round(0.999*numel(sv)));
        hold off, imagesc(fourier, [minv maxv]), axis off, colormap jet, axis image
        colorbar
    else
        axes(ha2(10)); 
        axis off;
    end
end

set(ha2(1:9),'XTickLabel',''); set(ha2,'YTickLabel','')




