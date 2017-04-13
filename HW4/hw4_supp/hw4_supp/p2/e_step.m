function alphas = e_step(x, sigma, mu_s, beta)

[images, annotators] = size(x);
alphas = zeros(images, annotators, 2);

for i = 1:images
    for j = 1:annotators
        if x(i, j) ~= 0  % Only follow this process is the image has been reviewd by this annotator
            z_0 = (1 - beta)/10;
            z_1 = beta*normpdf(x(i, j), mu_s(i), sigma);
            alphas(i, j, 1) = z_0/(z_0 + z_1);
            alphas(i, j, 2) = z_1/(z_0 + z_1);
        end
    end
end

