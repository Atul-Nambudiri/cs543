function [newX, newY] = predictTranslation(startX, startY, Ix, Iy, im0, im1)

[xSize, ySize, z] = size(im0);
Ix2 = Ix.^2;
Iy2 = Iy.^2;
Ixy = Ix.*Iy;

newX = startX;
newY = startY;

if newX - 7 < 1 || newX + 7 > xSize || newY - 7 < 1 || newY + 7 > ySize
     newX = -1;
     newY = -1;
     return
end

for i = 1:5 
    [gridX, gridY] = meshgrid(-7:7, -7:7);
    res = interp2(Ix2, startX + gridX, startY + gridY);
    if isnan(res(1, 1))
        newX = -1;
        newY = -1;
        return;
    end
    mat = [sum(sum(interp2(Ix2, startX + gridX, startY + gridY))) sum(sum(interp2(Ixy, startX + gridX, startY + gridY))); sum(sum(interp2(Ixy, startX + gridX, startY + gridY))) sum(sum(interp2(Iy2, startX + gridX, startY + gridY)))];
    t = interp2(im1, newX + gridX, newY + gridY) - interp2(im0, startX + gridX, startY + gridY);
    t_mat = [-sum(sum(interp2(Ix, startX + gridX, startY + gridY) .* t)); -sum(sum(interp2(Iy, startX + gridX, startY + gridY) .* t))];
    uv = mat\t_mat;
    newX = double(newX) + uv(1);
    newY = double(newY) + uv(2);
    if newX - 7 < 1 || newX + 7 > xSize || newY - 7 < 1 || newY + 7 > ySize
        newX = -1;
        newY = -1;
        return
    end 
end







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