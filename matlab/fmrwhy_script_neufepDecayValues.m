bids_dir = '/Volumes/My Passport for Mac/NEUFEPME_data_BIDS';
me_dir = fullfile(bids_dir, 'derivatives', 'fmrwhy-multiecho');
preproc_dir = fullfile(bids_dir, 'derivatives', 'fmrwhy-preproc');
options.anat_template_session = [];
options.preproc_dir = preproc_dir;
sub = '004';

% Template
t2star_fn = fullfile(me_dir, ['sub-' sub], 'func', ['sub-' sub '_task-rest_run-1_desc-MEparams_t2star.nii']);
s0_fn = fullfile(me_dir, ['sub-' sub], 'func', ['sub-' sub '_task-rest_run-1_desc-MEparams_s0.nii']);
error_fn = fullfile(me_dir, ['sub-' sub], 'func', ['sub-' sub '_task-rest_run-1_desc-MEparams_sserror.nii']);
% template_tsnr_fn = '/Users/jheunis/Desktop/sample-data/NEUFEPME_data_BIDS/derivatives/fmrwhy-multiecho/sub-001/func/sub-001_task-rest_run-1_echo-2_desc-rapreproc_tsnr.nii';
% template_perc_fn = '/Users/jheunis/Desktop/sample-data/NEUFEPME_data_BIDS/derivatives/fmrwhy-multiecho/sub-001/func/sub-001_task-rest_run-1_echo-2_desc-rapreproc_tsnr.nii';

[p, frm, rg, dim] = fmrwhy_util_readOrientNifti(t2star_fn);
t2star_img = p.nii.img;
[Ni, Nj, Nk] = size(t2star_img);
[p, frm, rg, dim] = fmrwhy_util_readOrientNifti(s0_fn);
s0_img = p.nii.img;
% [p, frm, rg, dim] = fmrwhy_util_readOrientNifti(error_fn);
% error_img = p.nii.img;

img = t2star_img;
template_img = zeros(size(img));
masks = fmrwhy_util_loadOrientMasks(bids_dir, sub, options);
I_mask = masks.brain_mask_I; 
template_img(I_mask) = img(I_mask);

% Stats
% tmap = '/Users/jheunis/Desktop/sample-data/NEUFEPME_data_BIDS/derivatives/fmrwhy-stats/sub-001/task-motor_run-1/spmT_0001.nii';
% tmap_clusters = '/Users/jheunis/Desktop/sample-data/NEUFEPME_data_BIDS/derivatives/fmrwhy-stats/sub-001/task-motor_run-1/spmT_0001_nary_clusters.nii';
% %tmap = '/Users/jheunis/Desktop/sample-data/NEUFEPME_data_BIDS/derivatives/fmrwhy-stats/sub-001/task-emotion_run-1/spmT_0001.nii';
% %tmap_clusters = '/Users/jheunis/Desktop/sample-data/NEUFEPME_data_BIDS/derivatives/fmrwhy-stats/sub-001/task-emotion_run-1/spmT_0001_nary_clusters.nii';
% [ptmap, frm3, rg3, dim3] = fmrwhy_util_readOrientNifti(tmap);
% [ptmapc, frm3, rg3, dim3] = fmrwhy_util_readOrientNifti(tmap_clusters);
% stats_img = fmrwhy_util_maskImage(double(ptmap.nii.img), double(ptmapc.nii.img));
stats_img = [];
overlay_img = [];

% ROIs
roi_lmotor_fn = fullfile(preproc_dir, ['sub-' sub], 'anat', ['sub-' sub '_space-individual_desc-rleftMotor_roi.nii']);
roi_bamygdala_fn = fullfile(preproc_dir, ['sub-' sub], 'anat', ['sub-' sub '_space-individual_desc-rBilateralAmygdala_roi.nii']);
roi_fns = {roi_lmotor_fn, roi_bamygdala_fn};
roi_names = {'motor', 'amygdala', 'GM', 'WM', 'CSF'};
% [p1, frm1, rg1, dim1] = fmrwhy_util_readOrientNifti(roi_lmotor_fn);
% [p2, frm2, rg2, dim2] = fmrwhy_util_readOrientNifti(roi_bamygdala_fn);
% %roi_img = {};
% %roi_img{1} = fmrwhy_util_createBinaryImg(p1.nii.img, 0.1);
% %roi_img{2} = fmrwhy_util_createBinaryImg(p2.nii.img, 0.1);
% roi1_img = fmrwhy_util_createBinaryImg(p1.nii.img, 0.1);
% roi2_img = fmrwhy_util_createBinaryImg(p2.nii.img, 0.1);

% roi_fns = {roi_lmotor_fn};
roi_img = {};
I_roi = {};
% overlay_img = zeros(dim);
for i = 1:numel(roi_fns)
    [p, ~, ~, ~] = fmrwhy_util_readOrientNifti(roi_fns{i});
    roi_img{i} = fmrwhy_util_createBinaryImg(p.nii.img, 0.1);
    roi_img_2D{i} = reshape(roi_img{i}, Ni*Nj*Nk, 1);
    I_roi{i} = find(masks.GM_mask_2D & roi_img_2D{i});
end
I_roi{3} = masks.GM_mask_I;
I_roi{4} = masks.WM_mask_I;
I_roi{5} = masks.CSF_mask_I;

mean_t2star = {};
mean_s0 = {};
t2star_2D = t2star_img(:);
s0_2D = s0_img(:);
for i = 1:numel(I_roi)
    roi_names{i}
    mean_t2star{i} = nanmean(t2star_2D(I_roi{i}))
    mean_s0{i} = nanmean(s0_2D(I_roi{i}))
end

% Parameters
% saveAs_fn = '/Users/jheunis/Desktop/blabla.png';
saveAs_fn = [];
columns = 9;
rotate = 1;
str = '';
clrmp = 'hot';
% clrmp = 'parula';
visibility = 'on';
shape = 'max';
%cxs = [0 250];
cxs = [0 5000];
cxs = [0 20000];
cxs = [0 180];
stats_clrmp = [];
clrbar = true;
roi_rgbcolors = [148, 239, 255];

% Call function
%output = fmrwhy_util_createStatsOverlayMontage(template_img, stats_img, roi_img, columns, rotate, str, clrmp, visibility, shape, cxs, stats_clrmp, roi_rgbcolors, saveAs_fn)
output = fmrwhy_util_createStatsOverlayMontage(template_img, stats_img, overlay_img, columns, rotate, str, clrmp, visibility, shape, cxs, stats_clrmp, roi_rgbcolors, clrbar, saveAs_fn)