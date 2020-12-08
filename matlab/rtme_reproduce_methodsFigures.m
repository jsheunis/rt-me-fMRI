% -----
% SETUP
% -----
clear;
% Locate settings file
settings_fn = '/Users/jheunis/Documents/PYTHON/rtme-fMRI/matlab/fmrwhy_settings_rtmefMRI.m';
% Get fmrwhy defaults
options = fmrwhy_defaults();
% Check fmrwhy dependencies
options = fmrwhy_util_checkDependencies(options);
% Run settings file ==> populates study/data-specific fields in the options structure, including BIDS variables
run(settings_fn);
% Setup fmrwhy derivative directories on workflow level
options = fmrwhy_bids_setupQcDerivDirs(options.bids_dir, options);
% Validate settings
options = fmrwhy_settings_validate(options)
% % Load the subjects
% subs = options.subjects_output;

figure_dir = fullfile(options.deriv_dir, 'rtme-figures-v2');
if ~exist(figure_dir, 'dir')
    mkdir(figure_dir);
end

% ---------
% Figure 01: Single images of echos to show decay
% ---------
% sub-001_task_rest-run-2, echo 1, echo 2, echo 3, volume X.
sub = '001';
ses = '';

% get subject specific template data
task = 'rest';
run = '1';
% Mask details
masks = fmrwhy_util_loadMasks(options.bids_dir, sub, options);
mask_fn = masks.brain_mask_fn;
mask_img = masks.brain_mask_3D;
I_mask = masks.brain_mask_I;
masks_oriented = fmrwhy_util_loadOrientMasks(options.bids_dir, sub, options);
mask_img_oriented = masks_oriented.brain_mask_3D;
I_mask_oriented = masks_oriented.brain_mask_I;
% Functional volume template
% template_fn = fullfile(options.sub_dir_preproc, 'func', ['sub-' sub '_task-' options.template_task '_run-' options.template_run '_space-individual_bold.nii']);
% ROIs
% roi_fns = {};
% roi_fns{1} = fullfile(options.anat_dir_preproc, ['sub-' sub '_space-individual_desc-rleftMotor_roi.nii']);
% roi_fns{2} = fullfile(options.anat_dir_preproc, ['sub-' sub '_space-individual_desc-rbilateralAmygdala_roi.nii']);
% compare_roi_txt = {'left motor cortex', 'bilateral amygdala'};
% roi_desc_txt = {'lmotor', 'bamygdala'};
% % Grab+load ROI image data; get ROI indices; combine ROI image data into a single overlay image
% roi_img = {};
% I_roi = {};
% overlay_img = zeros(size(mask_img_oriented));
% for i = 1:numel(roi_fns)
%     [p, frm, rg, dim] = fmrwhy_util_readOrientNifti(roi_fns{i});
%     roi_img{i} = fmrwhy_util_createBinaryImg(p.nii.img, 0.1);
%     I_roi{i} = find(roi_img{i}(:));
%     overlay_img = overlay_img | roi_img{i};
% end

run = '2';
echoes = {'1', '2', '3'};
volume_nr = 1;
slices = 2:2:18;
for e = 1:numel(echoes)
    [filename, filepath] = fmrwhy_bids_constructFilename('func', 'sub', sub, 'task', task, 'run', run, 'echo', echoes{e}, 'desc', 'rapreproc', 'ext', '_bold.nii');
    bold_nii = fullfile(options.deriv_dir, 'fmrwhy-preproc', ['sub-' sub], 'func', filename);
    bold_vol_png = fullfile(figure_dir, strrep(filename, '_bold.nii', '_singleVol_bold.png'));
    bold_mean_png = fullfile(figure_dir, strrep(filename, '_bold.nii', '_mean_bold.png'));
    if ~exist(bold_vol_png)
        [p, frm, rg, dim] = fmrwhy_util_readOrientNifti(bold_nii);
        bold_vol_img = fmrwhy_util_maskImage(double(p.nii.img(:,:,:,volume_nr)), mask_img_oriented);
        bold_mean_img = fmrwhy_util_maskImage(mean(double(p.nii.img(:,:,:,:)), 4), mask_img_oriented);
        bold_vol_montage = fmrwhy_util_createStatsOverlayMontage(bold_vol_img(:,:,slices), [], [], 9, 1, '', 'gray', 'off', 'maxwidth', [], [], [], false, bold_vol_png);
        bold_mean_montage = fmrwhy_util_createStatsOverlayMontage(bold_mean_img(:,:,slices), [], [], 9, 1, '', 'gray', 'off', 'maxwidth', [], [], [], false, bold_mean_png);
    end
end

% ---------
% Figure 02: T2* and S0 estimations
% ---------


% ---------
% Figure 03: Volumes from all six timeseries to show dropout and signal recovery
% ---------
% From rest run 2

task = 'rest';
run = '2';
echoes = ['1', '2', '3'];
descriptions = {'', 'combinedMEt2star', 'combinedMEtsnr', 'combinedMEte', 'combinedMEt2starFIT', 't2starFIT'};
volume_nr = 1;
slices = 2:2:18;
for d = 1:numel(descriptions)
    desc = descriptions{d};
    if d==1
        continue;
    end
    [filename, filepath] = fmrwhy_bids_constructFilename('func', 'sub', sub, 'task', task, 'run', run, 'desc', desc, 'ext', '_bold.nii');
    bold_nii = fullfile(options.deriv_dir, 'fmrwhy-multiecho', ['sub-' sub], 'func', filename);
    bold_vol_png = fullfile(figure_dir, strrep(filename, '_bold.nii', '_singleVol_bold.png'));
    bold_mean_png = fullfile(figure_dir, strrep(filename, '_bold.nii', '_mean_bold.png'));

    if d==6
        cxs = [0 130];
    else
        cxs = [0 3000];
    end
    if ~exist(bold_vol_png)
        [p, frm, rg, dim] = fmrwhy_util_readOrientNifti(bold_nii);
        bold_vol_img = fmrwhy_util_maskImage(double(p.nii.img(:,:,:,volume_nr)), mask_img_oriented);
        bold_mean_img = fmrwhy_util_maskImage(mean(double(p.nii.img(:,:,:,:)), 4), mask_img_oriented);
        if d ==2
            koekies = bold_mean_img;
        end
        bold_vol_montage = fmrwhy_util_createStatsOverlayMontage(bold_vol_img(:,:,slices), [], [], 9, 1, '', 'gray', 'off', 'maxwidth', cxs, [], [], true, bold_vol_png);
        bold_mean_montage = fmrwhy_util_createStatsOverlayMontage(bold_mean_img(:,:,slices), [], [], 9, 1, '', 'gray', 'off', 'maxwidth', cxs, [], [], true, bold_mean_png);
    end
end

% ---------
% Figure 04: Volumes from tSNR of all six timeseries to show dropout and signal recovery
% ---------

task = 'rest';
run = '2';
echoes = ['1', '2', '3'];
descriptions = {'rapreproc', 'combinedMEt2star', 'combinedMEtsnr', 'combinedMEte', 'combinedMEt2starFIT', 't2starFIT'};
volume_nr = 1;
slices = 2:2:18;
for d = 1:numel(descriptions)
    desc = descriptions{d};
    if d==1
        [filename, filepath] = fmrwhy_bids_constructFilename('func', 'sub', sub, 'task', task, 'run', run, 'echo', '2', 'desc', desc, 'ext', '_tsnr.nii');
        tsnr_nii = fullfile(options.deriv_dir, 'fmrwhy-multiecho', ['sub-' sub], 'func', filename);
    else
        [filename, filepath] = fmrwhy_bids_constructFilename('func', 'sub', sub, 'task', task, 'run', run, 'desc', desc, 'ext', '_tsnr.nii');
        tsnr_nii = fullfile(options.deriv_dir, 'fmrwhy-multiecho', ['sub-' sub], 'func', filename);
    end
    
    tsnr_vol_png = fullfile(figure_dir, strrep(filename, '.nii', '.png'));
    
    if ~exist(tsnr_vol_png)
        [p, frm, rg, dim] = fmrwhy_util_readOrientNifti(tsnr_nii);
        tsnr_vol_img = fmrwhy_util_maskImage(double(p.nii.img(:,:,:,volume_nr)), mask_img_oriented);
        tsnr_vol_montage = fmrwhy_util_createStatsOverlayMontage(tsnr_vol_img(:,:,slices), [], [], 9, 1, '', 'hot', 'off', 'maxwidth', [0 250], [], [], true, tsnr_vol_png);
    end
end