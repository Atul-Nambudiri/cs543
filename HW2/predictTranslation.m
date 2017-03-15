function [newX, newY] = predictTranslation(startX, startY, Ix, Iy, im0, im1)

[xSize, ySize, z] = size(im0);

newX = startX;
newY = startY;

[sgridX, sgridY] = meshgrid(startX-7:startX+7, startY-7:startY+7);
Intx = interp2(Ix, sgridX, sgridY);
Inty = interp2(Iy, sgridX, sgridY);
Iold = interp2(im0, sgridX, sgridY);
mat = [sum(sum(Intx .* Intx)) sum(sum(Intx .* Inty)); sum(sum(Intx .* Inty)) sum(sum(Inty .* Inty))];

for i = 1:10
    [ngridX, ngridY] = meshgrid(newX-7:newX+7, newY-7:newY+7);
    Inew = interp2(im1, ngridX, ngridY);
    if sum(sum(isnan(Inew(1, 1)))) > 0
        newX = -1;
        newY = -1;
        return;
    end
    t = Inew - Iold;
    t_mat = [-sum(sum(Intx .* t)); -sum(sum(Inty .* t))];
    uv = mat\t_mat;
    newX = double(newX) + uv(1);
    newY = double(newY) + uv(2);
    if newX - 7 < 1 || newX + 7 > xSize || newY - 7 < 1 || newY + 7 > ySize
        newX = -1;
        newY = -1;
        return
    end 
end