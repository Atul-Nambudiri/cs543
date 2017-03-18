function vp = getVanishingPoint(im)
% output vanishing point, input image

im = imread('kyoto_street.JPG');
% figure(1), hold off, imagesc(im)
% hold on 
% 
% % Allow user to input line segments; compute centers, directions, lengths
% disp('Set at least two lines for vanishing point')
% lines = zeros(3, 0);
% line_length = zeros(1,0);
% centers = zeros(3, 0);
% while 1
%     disp(' ')
%     disp('Click first point or q to stop')
%     [x1,y1,b] = ginput(1);    
%     if b=='q'        
%         break;
%     end
%     disp('Click second point');
%     [x2,y2] = ginput(1);
%     
%     plot([x1 x2], [y1 y2], 'b')
%     lines(:, end+1) = real(cross([x1 y1 1]', [x2 y2 1]'));
%     line_length(end+1) = sqrt((y2-y1)^2 + (x2-x1).^2);
%     centers(:, end+1) = [x1+x2 y1+y2 2]/2;
% end

%% Calculate three vanishing points 
% Insert code here to compute vp (3x1 vector in homogeneous coordinates)

lines = [-850.758620689655 -1181.79310344828 -539.586206896552 -158.896551724138 -16.5517241379312 -13.2413793103447 -62.8965517241377 -59.5862068965521 -16.5517241379307; 20.4387096774194 -22.7096774193548 -20.4387096774193 649.496774193548 438.296774193548 172.593548387097 177.135483870968 231.638709677419 -165.780645161290; 1154891.21245829 879558.859176863 234568.706562848 85569.0892102339 -539807.843381535 -168385.637374862 -321855.441156841 -408115.968854283 255000.873859844];

vps = zeros(3, 3);
for i = 0:2
    p1 = real(cross(lines(:, i*3 + 1), lines(:, i*3 + 2)));
    p2 = real(cross(lines(:, i*3 + 2), lines(:, i*3 + 3)));
    p3 = real(cross(lines(:, i*3 + 1), lines(:, i*3 + 3)));
    for j = 1:3
        vps(j, i+1) = (p1(j) + p2(j) + p3(j))/3;
    end
end

vpsuv = zeros(2, 3);
for i = 1:3
    vpsuv(1, i) = vps(1, i)/vps(3, i);
    vpsuv(2, i) = vps(2, i)/vps(3, i);
end

%% Graph points
for i = 0:2
    figure; 
    imagesc(im);
    hold on 
    vp = vps(:, i+1);
    bx1 = min(1, vp(1)/vp(3))-10; bx2 = max(size(im,2), vp(1)/vp(3))+10;
    by1 = min(1, vp(2)/vp(3))-10; by2 = max(size(im,1), vp(2)/vp(3))+10;
    for k = 1:3
        if lines(1, i*3 + k)<lines(2, i*3 + k)
            pt1 = real(cross([1 0 -bx1]', lines(:, i*3 + k)));
            pt2 = real(cross([1 0 -bx2]', lines(:, i*3 + k)));
        else
            pt1 = real(cross([0 1 -by1]', lines(:, i*3 + k)));
            pt2 = real(cross([0 1 -by2]', lines(:, i*3 + k)));
        end
        pt1 = pt1/pt1(3);
        pt2 = pt2/pt2(3);
        plot([pt1(1) pt2(1)], [pt1(2) pt2(2)], 'g', 'Linewidth', 1);
    end
    plot(vp(1)/vp(3), vp(2)/vp(3), '*r');
    axis image;
    axis([bx1 bx2 by1 by2]);
    hold off;
end

%% Graph horizon line
figure; 
imagesc(im);
hold on 

vp1 = vertcat(vpsuv(:, 2), 1);
vp2 = vertcat(vpsuv(:, 3), 1);
vp3 = vps(:, 1);

line = real(cross(vp2, vp1));
mag = sqrt(line(1)^2 + line(2)^2);
line(1) = line(1)/mag;
line(2) = line(2)/mag;
line(3) = line(3)/mag;

bx1 = min(1, vp3(1)/vp3(3))-10; 
bx2 = max(size(im,2), vp3(1)/vp3(3))+10;
by1 = min(1, vp3(2)/vp3(3))-10; 
by2 = max(size(im,1), vp3(2)/vp3(3))+10;


if line(1) < line(2)
    pt1 = real(cross([1 0 -bx1]', line));
    pt2 = real(cross([1 0 -bx2]', line));
else
    pt1 = real(cross([0 1 -by1]', line));
    pt2 = real(cross([0 1 -by2]', line));
end
pt1 = pt1/pt1(3);
pt2 = pt2/pt2(3);

plot([pt1(1) pt2(1)], [pt1(2) pt2(2)], 'g', 'Linewidth', 1);
axis([bx1 bx2 by1 by2]);
axis image;
hold off;

%% Calculate Focal Length and (u0,v0)

syms f u v

% vptm = vertcat(vertcat(transpose(vps(:, 1)), transpose(vps(:, 1))), transpose(vps(:, 2)));
% vpm = horzcat(horzcat(vps(:, 2), vps(:, 3)), vps(:, 3));

k = [f 0 u; 0 f v; 0 0 1];
kinv = [1/f 0 -u/f; 0 1/f -v/f; 0 0 1];

eqn1 = transpose(vertcat(vpsuv(:, 1), 1)) * transpose(kinv) * kinv * vertcat(vpsuv(:, 2), 1) == 0;
eqn2 = transpose(vertcat(vpsuv(:, 1), 1)) * transpose(kinv) * kinv * vertcat(vpsuv(:, 3), 1) == 0;
eqn3 = transpose(vertcat(vpsuv(:, 2), 1)) * transpose(kinv) * kinv * vertcat(vpsuv(:, 3), 1) == 0;

X = solve([eqn1, eqn2, eqn3], [f; u; v]);

u0 = double(X.u(2))
v0 = double(X.v(1))
f1 = double(X.f(1))

%% Solve for R

R = zeros(3, 3);

R(:, 1) = [(vpsuv(1, 3) - u0)/f1; (vpsuv(2, 3) - u0)/f1; 1];
R(:, 2) = [(vpsuv(1, 1) - u0)/f1; (vpsuv(2, 1) - u0)/f1; 1];
R(:, 3) = [(vpsuv(1, 2) - u0)/f1; (vpsuv(2, 2) - u0)/f1; 1];

% Normalize the rotation matrix, accoriding to Piazza post #184
R = normc(R);

R(:, 2) = real(cross(R(:,1), R(:, 3)));
R(:, 3) = real(cross(R(:,1), R(:, 2)));

R

R * R'
