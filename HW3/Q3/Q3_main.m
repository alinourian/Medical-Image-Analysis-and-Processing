clear; clc; close all;

im = imread('image3.png');
im = im2double(im);

im_noisy = imnoise(im, 'gaussian');

% Denoise the image using anisotropic diffusion
niter = 2;          % Number of iterations
kappa = 25;         % Conduction coefficient
lambda = 0.18;       % Maximum value for stability
option = 1;         % Diffusion equation No 2
aniso_im_denoised = anisodiff(im_noisy, niter, kappa, lambda, option);

% Denoise the image using isotropic diffusion
lambda = 0.1;
constant = 1.7;
iso_im_denoised = isodiff(im_noisy, lambda, constant);

subplot(2,2,1); imshow(im);
title(['Original image: SSIM=', num2str(ssim(im, im)), ', NIQE=', num2str(niqe(im))]);
subplot(2,2,2); imshow(im_noisy);
title(['Noisy image: SSIM=', num2str(ssim(im_noisy, im)), ', NIQE=', num2str(niqe(im_noisy))]);

subplot(2,2,3); imshow(aniso_im_denoised);
title(['Aniso Denoised image: SSIM=', num2str(ssim(aniso_im_denoised, im)), ', NIQE=', num2str(niqe(aniso_im_denoised))]);
subplot(2,2,4); imshow(iso_im_denoised);
title(['Iso Denoised image: SSIM=', num2str(ssim(iso_im_denoised, im)), ', NIQE=', num2str(niqe(iso_im_denoised))]);


%% ============ Cross-Validation for Selecting Hyperparameters ============
%% Cross-Validation for Aniso
ssims = [];
niqes = [];
for lambda=0.15
    t = 20:5:100;
    for kappa=20:5:100
        aniso_im_denoised = anisodiff(im_noisy, niter, kappa, lambda, option);
        ssim_score = ssim(aniso_im_denoised, im);
        niqe_score = niqe(aniso_im_denoised);
        ssims = [ssims, ssim_score];
        niqes = [niqes, niqe_score];
        fprintf("lambda=%.2f, kappa=%.2f, ", lambda, kappa);
        fprintf("ssim=%.2f, niqe=%.2f\n", ssim_score, niqe_score);
    end
    figure;
    subplot(1, 2, 1); plot(t, ssims); title('SSIM')
    subplot(1, 2, 2); plot(t, niqes); title('NIQE');
end
%% Cross-Validation for Iso
ssims = [];
niqes = [];
for lambda = 0.1
    t = 1.1:0.05:2;
    for constant = 1.1:0.05:2
        iso_im_denoised = isodiff(im_noisy, lambda, constant);
        ssim_score = ssim(iso_im_denoised, im);
        niqe_score = niqe(iso_im_denoised);
        ssims = [ssims, ssim_score];
        niqes = [niqes, niqe_score];
        fprintf("lambda=%.2f, c=%.2f, ", lambda, constant);
        fprintf("ssim=%.2f, niqe=%.2f\n", ssim_score, niqe_score);
    end
%     figure;
%     subplot(1, 2, 1); plot(t, ssims); title('SSIM')
%     subplot(1, 2, 2); plot(t, niqes); title('NIQE');
end
