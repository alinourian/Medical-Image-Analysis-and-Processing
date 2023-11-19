% Example usage of the TV_Chambolle function
clear; clc; close all;

img = imread('TV.png');
img = im2double(img);
noisy_img = imnoise(img, 'gaussian', 0.01);


w1 = zeros(size(noisy_img));
w2 = zeros(size(noisy_img));
lambda = 16;       % Fidelity constant
alpha = 0.13;       % Step size
maxIterations = 100;
tolerance = 1e-4;
verbose = true;

[u_GPCL, ~, ~, Energy_GPCL, Dgap_GPCL, ~, iter_GPCL] = ...
    TV_GPCL(w1, w2, noisy_img, lambda, alpha, maxIterations, tolerance, verbose);

[u_Chambolle, ~, ~, Energy_Chambolle, Dgap_Chambolle, ~, iter_Chambolle] = ...
    TV_Chambolle(w1, w2, noisy_img, lambda, alpha, maxIterations, tolerance, verbose);

figure;
subplot(2, 4, 1);
imshow(img);
title('Original Image');
subplot(2, 4, 2);
imshow(noisy_img);
title(['Noisy Image, PSNR=', num2str(psnr(noisy_img, img))]);

subplot(2, 4, 3);
imshow(u_GPCL);
title(['Denoised by TV\_GPCL, PSNR=', num2str(psnr(u_GPCL, img))]);
% Plot the convergence information
subplot(2, 4, 5);
semilogx(0:iter_GPCL, Energy_GPCL);
xlabel('Iteration');
ylabel('Energy');
title('Objective Function (TV\_GPCL)');
subplot(2, 4, 6);
semilogx(0:iter_GPCL, Dgap_GPCL);
xlabel('Iteration');
ylabel('Duality Gap');
title('Duality Gap (TV\_GPCL)');

subplot(2, 4, 4);
imshow(u_Chambolle);
title(['Denoised by TV\_Chambolle, PSNR=', num2str(psnr(u_Chambolle, img))]);
% Plot the convergence information
subplot(2, 4, 7);
semilogx(0:iter_Chambolle, Energy_Chambolle);
xlabel('Iteration');
ylabel('Energy');
title('Objective Function (TV\_Chambolle)');
subplot(2, 4, 8);
semilogx(0:iter_Chambolle, Dgap_Chambolle);
xlabel('Iteration');
ylabel('Duality Gap');
title('Duality Gap (TV\_Chambolle)');
%% Cross-Validation to find hyperparameters
mses = [];

for i_lambda = 14:0.05:16
    for i_alpha = 0.01:0.01:0.2
        [u_GPCL, ~, ~, ~, ~, ~, ~] = ...
            TV_Chambolle(w1, w2, noisy_img, i_lambda, i_alpha, maxIterations, tolerance, 0);

        mse = sum((u_GPCL - img) .^ 2, 'all');
        mses = [mses, mse];
        fprintf("lbd=%f, alpha=%f, mse=%f\n", i_lambda, i_alpha, mse);
    end
end

