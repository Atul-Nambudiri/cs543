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
    mu_s(i) = x_alpha_sum/sum(alphas(i, :, 2));
end


%Sigma
for i = 1:images
    for j = 1:annotators
        if x(i, j) ~= 0  % Only follow this process is the image has been reviewd by this annotator
            sigma_sum = sigma_sum  +  (x(i, j) - mu_s(i))^2 * alphas(i, j, 2);
        end
    end
end

sigma = sigma_sum/sum(sum(alphas(:, :, 2)));
sigma = sqrt(sigma);

%beta
beta = sum(sum(alphas(:, :, 2)))/sum(sum(sum(alphas)));

%m
for j = 1:annotators
    m_0 = 0;
    m_1 = 0;
    
    for i = 1:images
        if x(i, j) ~= 0  % Only follow this process is the image has been reviewd by this annotator
            m_0 = m_0 + alphas(i, j, 1);
            m_1 = m_1 + alphas(i, j, 2);
        end
    end
    
    if m_0 > m_1
        m_s(j) = 1;
    else
        m_s(j) = 2;
    end
end