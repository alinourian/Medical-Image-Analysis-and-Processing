clear; clc; close all;

im = imread('image_anisotropic.png');
im = im2double(im);

im_noisy = imnoise(im, 'gaussian');

% Denoise the image using anisotropic diffusion
niter = 7;            % Number of iterations
kappa = 5;            % Conduction coefficient
lambda = 0.05;        % Maximum value for stability
option = 1;           % Diffusion equation No 2
aniso_im_denoised = anisotropic(im_noisy, niter, kappa, lambda, option);

figure;
subplot(1,3,1); imshow(im);
title(['Original image: PSNR=', num2str(psnr(im, im))]);
subplot(1,3,2); imshow(im_noisy);
title(['Noisy image: PSNR=', num2str(psnr(im_noisy, im))]);
subplot(1,3,3); imshow(aniso_im_denoised);
title(['Aniso Denoised image: PSNR=', num2str(psnr(aniso_im_denoised, im))]);

%% Cross-Validation for Aniso
psnrs = [];
for lambda=0.05:0.05:0.25
    t = 0:5:20;
    for kappa=t
        aniso_im_denoised = anisotropic(im_noisy, niter, kappa, lambda, option);
        psnr_score = psnr(aniso_im_denoised, im);
        psnrs = [psnrs, psnr_score];
        fprintf("lambda=%.2f, kappa=%.2f, ", lambda, kappa);
        fprintf("psnr=%.6f\n", psnr_score);
    end
%     figure;
%     subplot(1, 2, 1); plot(t, psnrs); title('PSNR')
end