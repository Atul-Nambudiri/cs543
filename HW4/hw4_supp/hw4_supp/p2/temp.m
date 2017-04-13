load('annotation_data.mat');

sigma = 0.5;
mu_s = zeros(150, 1);
mu_s = mu_s + 2;  
beta = .5;

x = zeros(150, 25);

for i = 1:length(annotation_scores)
    image = image_ids(i);
    annotator = annotator_ids(i);
    x(image, annotator) = annotation_scores(i);
end

for count = 1:2
    alphas = e_step(x, sigma, mu_s, beta);
    [mu_s, sigma, beta, m_s] = m_step(x, alphas);
    figure(count)
    plot(m_s, ones(25, 1));
end


function alphas = e_step(x, sigma, mu_s, beta)

[images, annotators] = size(x);
alphas = zeros(images, annotators, 2);

for i = 1:images
    for j = 1:annotators
        z_0 = (1 - beta)/10;
        z_1 = beta/(sqrt(2 * pi));
        z_1 = z_1 * exp(-((x(i, j) - mu_s(i))^2)/(2 * sigma^2));
        alphas(i, j, 1) = z_0/(z_0 + z_1);
        alphas(i, j, 2) = z_1/(z_0 + z_1);
    end
end

function [mu_s, sigma, beta, m_s] = m_step(x, alphas)

[images, annotators] = size(x);
sigma = 0;
mu_s = zeros(images, 1);
m_s = zeros(annotators, 1);

sigma_sum = 0;

%Mus
for i = 1:images
    x_alpha_sum = 0;
    for j = 1:annotators
        x_alpha_sum = x_alpha_sum + x(i, j) * alphas(i, j, 2);
    end
    mu_s(i) = x_alpha_sum/sum(alphas(1, :, 2));
end

%Sigma
for i = 1:images
    for j = 1:annotators
        sigma_sum = sigma_sum  +  (x(i, j) - mu_s(i))^2 * alphas(i, j, 2);
    end
end

sigma = sigma_sum/sum(sum(alphas(:, :, 1)));
sigma = sqrt(sigma);

%beta
beta = sum(sum(alphas(i, j, 1)))/sum(sum(sum(alphas)));

%m
for j = 1:annotators
    top_sum_0 = 0;
    top_sum_1 = 0;
    for i = 1:images
        top_sum_0 = top_sum_0 + alphas(i, j, 1) * (1 - beta);
        top_sum_1 = top_sum_1 + alphas(i, j, 2) * (beta);
    end
    m_0 = top_sum_0/(top_sum_0 + top_sum_1);
    m_1 = top_sum_1/(top_sum_0 + top_sum_1);
    
    m_0
    m_1
    
    if m_0 > m_1
        m_s(j) = 1;
    else
        m_s(j) = 2;
    end
end