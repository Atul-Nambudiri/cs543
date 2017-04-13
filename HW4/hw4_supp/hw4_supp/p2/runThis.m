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

alphas = 1;
prev_alphas = 0;

count = 0
while ~isequal(alphas, prev_alphas)
    alphas = e_step(x, sigma, mu_s, beta);
    [mu_s, sigma, beta, m_s] = m_step(x, alphas);
    count = count + 1
    sum(sum(alphas(:, :, 2)))
end


