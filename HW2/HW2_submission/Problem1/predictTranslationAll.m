function [newXs, newYs] = predictTranslationAll(startXs, startYs, im0, im1)
newXs = zeros(size(startXs));
newYs = zeros(size(startYs));

[Ix, Iy] = imgradientxy(im0);
for i = 1:length(startXs)
    if startXs(i) ~= -1
        [newX, newY] = predictTranslation(startXs(i), startYs(i), Ix, Iy, im0, im1);
        newXs(i) = newX;
        newYs(i) = newY;
    else
        newXs(i) = -1;
        newYs(i) = -1;
    end;
end;