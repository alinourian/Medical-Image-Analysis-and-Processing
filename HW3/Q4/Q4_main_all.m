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

%% function
function diff = anisotropic(im, niter, kappa, lambda, option, img)
    im = double(im);
    [rows,cols] = size(im);
    diff = im;

    for i = 1:niter
      % Construct diffl which is the same as diff but has an extra padding of zeros around it.
      diffl = zeros(rows+2, cols+2);
      diffl(2:rows+1, 2:cols+1) = diff;

      % North, South, East and West differences
      deltaN = diffl(1:rows,2:cols+1)   - diff;
      deltaS = diffl(3:rows+2,2:cols+1) - diff;
      deltaE = diffl(2:rows+1,3:cols+2) - diff;
      deltaW = diffl(2:rows+1,1:cols)   - diff;

      % Conduction
      if option == 1
        cN = exp(-(deltaN/kappa).^2);
        cS = exp(-(deltaS/kappa).^2);
        cE = exp(-(deltaE/kappa).^2);
        cW = exp(-(deltaW/kappa).^2);
      elseif option == 2
        cN = 1./(1 + (deltaN/kappa).^2);
        cS = 1./(1 + (deltaS/kappa).^2);
        cE = 1./(1 + (deltaE/kappa).^2);
        cW = 1./(1 + (deltaW/kappa).^2);
      end

      diff = diff + lambda * (cN.*deltaN + cS.*deltaS + cE.*deltaE + cW.*deltaW);

      if nargin > 5
          R = psnr(diff, img);
          subplot(ceil(sqrt(niter)),ceil(sqrt(niter)), i);
          imagesc(diff), colormap(gray), axis image;
          title(['PSNR = ', num2str(R)]);
      end
    end
end
