load prob3.mat

set = [5, 30, 150, 70, 230, 100, 200, 90];
set2 = zeros(8, 2);
    
for i = 1:8
    pos1 = matches(set(i), 1);
    pos2 = matches(set(i), 2);
    set2(i, :) = [pos1, pos2];
end

plotmatches(im1,im2,[c1 r1]',[c2 r2]',set2')