load('annotation_data.mat');

x = zeros(150, 25);

for i = 1:length(annotation_scores)
    image = image_ids(i);
    annotator = annotator_ids(i);
    x(image, annotator) = annotation_scores(i);
end

mu_s = zeros(150, 1);
mu_s = mu_s + 6;
% mu_s = sum(x, 2)/5;
sigma = 2;
beta = .5;

alphas = zeros(1, 1, 2);
prev_alphas = ones(1, 1, 2);

count = 0
while count < 40 && ~(sum(sum(abs(alphas(:, :, 1) - prev_alphas(:, :, 1)))) < 1e-3)
    prev_alphas = alphas;
    alphas = e_step(x, sigma, mu_s, beta);
    [mu_s, sigma, beta, m_s] = m_step(x, alphas);
    count = count + 1
end

find(m_s == 1)

plot(1:150, mu_s(1:150));