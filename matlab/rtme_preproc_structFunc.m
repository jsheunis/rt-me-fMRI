% FUNCTION: rtme_preproc_structFunc
%--------------------------------------------------------------------------

% Copyright statement....

%--------------------------------------------------------------------------
% DEFINITION
%--------------------------------------------------------------------------

% Function for pre-real-time anatomical/structural to functionap
% preprocessing for a single subject. Steps include coregistering
% structural image to initial functional image, segmenting the coregistered
% structural image into tissue types, and reslicing the segments to the
% functional resolution image grid. Makes use of spm12 batch routines.
% If spm12 batch parameters are not explicitly set, defaults are assumed.

% STEPS:
% 1. Anatomical to functional space coregistration, use middle echo first volume rest run 1 as template - SPM12 coregister estimate
% 2. Segment coregistered anatomical image into tissue components - SPM12 unified segmentation
%     - Saves inverse transform from subject functional to MNI space
% 3. Reslice all to functional space grid (SPM reslice)
% 4. Create tissue compartment and whole brain masks

% INPUT:
% funcional0_fn     - filename of initial pre-real-time 3D functional volume template
% structural_fn     - filename of T1-weighted structural volume
% spm_dir           - SPM12 directory

% OUTPUT:
% output            - structure with filenames and data

%--------------------------------------------------------------------------
% STEPS
%--------------------------------------------------------------------------



%--------------------------------------------------------------------------

function output = rtme_preproc_structFunc(sub, defaults)

% Load required defaults
spm_dir = defaults.spm_dir;
preproc_dir = defaults.preproc_dir;
template_run = defaults.template_run;
template_task = defaults.template_task;
template_echo = defaults.template_echo;

% Grab files for preprocessing
% (Functional template is first volume of rest_run-1)
template_vol = fullfile(preproc_dir, sub, 'func', [sub '_task-' template_task '_run-' template_run '_echo-' template_echo '_bold_template.nii']);
structural_fn = fullfile(preproc_dir, sub, 'anat', [sub '_T1w.nii']);

% Structure to save outputs
output = struct;

% STEP 1 -- Coregister structural image to first dynamic image (estimate)
% This changes header of T1w nifti!!!!! (i.e. file should then not be used again for other purposes!!!!)
disp('1 - Coregistering structural to functional image space...');
spm('defaults','fmri');
spm_jobman('initcfg');
coreg_estimate = struct;
% Ref
coreg_estimate.matlabbatch{1}.spm.spatial.coreg.estimate.ref = {template_vol};
% Source
coreg_estimate.matlabbatch{1}.spm.spatial.coreg.estimate.source = {structural_fn};
% Other
% coreg_estimate.matlabbatch{1}.spm.spatial.coreg.estimate.other = {};
% Eoptions
coreg_estimate.matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
coreg_estimate.matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
coreg_estimate.matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
coreg_estimate.matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
% Run
spm_jobman('run',coreg_estimate.matlabbatch);
disp('done');


% STEP 2 -- Segmentation of coregistered structural image into GM, WM, CSF, etc
% (with implicit warping to MNI space, saving forward and inverse transformations)
disp('2 - Segmenting coregistered structural image into GM, WM, CSF, etc...');
spm('defaults','fmri');
spm_jobman('initcfg');
segmentation = struct;
% Channel
segmentation.matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
segmentation.matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
segmentation.matlabbatch{1}.spm.spatial.preproc.channel.write = [0 1];
segmentation.matlabbatch{1}.spm.spatial.preproc.channel.vols = {structural_fn};
% Tissue
for t = 1:6
    segmentation.matlabbatch{1}.spm.spatial.preproc.tissue(t).tpm = {[spm_dir filesep 'tpm' filesep 'TPM.nii,' num2str(t)]};
    segmentation.matlabbatch{1}.spm.spatial.preproc.tissue(t).ngaus = t-1;
    segmentation.matlabbatch{1}.spm.spatial.preproc.tissue(t).native = [1 0];
    segmentation.matlabbatch{1}.spm.spatial.preproc.tissue(t).warped = [0 0];
end
segmentation.matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
segmentation.matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
% Warp
segmentation.matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
segmentation.matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
segmentation.matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
segmentation.matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
segmentation.matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
segmentation.matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
segmentation.matlabbatch{1}.spm.spatial.preproc.warp.write=[1 1];
% Run
spm_jobman('run',segmentation.matlabbatch);
% Save filenames
[d, fn, ext] = fileparts(structural_fn);
output.forward_transformation = [d filesep 'y_' fn ext];
output.inverse_transformation = [d filesep 'iy_' fn ext];
output.gm_fn = [d filesep 'c1' fn ext];
output.wm_fn = [d filesep 'c2' fn ext];
output.csf_fn = [d filesep 'c3' fn ext];
output.bone_fn = [d filesep 'c4' fn ext];
output.soft_fn = [d filesep 'c5' fn ext];
output.air_fn = [d filesep 'c6' fn ext];
disp('done');


% STEP 3 -- Reslice all to functional-resolution image grid
disp('3 - Reslice all generated images to functional-resolution image grid');
spm('defaults','fmri');
spm_jobman('initcfg');
reslice = struct;
% Ref
reslice.matlabbatch{1}.spm.spatial.coreg.write.ref = {template_vol};
% Source
source_fns = {};
source_fns{1} = structural_fn;
[d, fn, ext] = fileparts(structural_fn);
for i = 2:7
    source_fns{i} = [d filesep 'c' num2str(i-1) fn ext];
end
reslice.matlabbatch{1}.spm.spatial.realign.write.data = source_fns';
% Roptions
reslice.matlabbatch{1}.spm.spatial.realign.write.roptions.interp = 4;
reslice.matlabbatch{1}.spm.spatial.realign.write.roptions.wrap = [0 0 0];
reslice.matlabbatch{1}.spm.spatial.realign.write.roptions.mask = 0;
reslice.matlabbatch{1}.spm.spatial.realign.write.roptions.prefix = 'r';
% Run
spm_jobman('run',reslice.matlabbatch);
% Save filenames
[d, fn, ext] = fileparts(structural_fn);
output.rstructural_fn = [d filesep 'r' fn ext];
output.rgm_fn = [d filesep 'rc1' fn ext];
output.rwm_fn = [d filesep 'rc2' fn ext];
output.rcsf_fn = [d filesep 'rc3' fn ext];
output.rbone_fn = [d filesep 'rc4' fn ext];
output.rsoft_fn = [d filesep 'rc5' fn ext];
output.rair_fn = [d filesep 'rc6' fn ext];
disp('done');


% STEP 4 -- Construct GM, WM, CSF and whole brain (GM+WM+CSF) masks
disp('4 - Construct GM, WM, CSF and whole brain (GM+WM+CSF) masks');
% Get binary 3D images for each tissue type, based on a comparison of
% the probability value for each tissue type per voxel (after applying
% a treshold on the probability values)
[output.GM_img_bin, output.WM_img_bin, output.CSF_img_bin] = rtme_util_createBinaryMasks(output.rgm_fn, output.rwm_fn, output.rcsf_fn, 0.5);
% combine binary images of all tissue types to generate mask
output.brain_img_bin = output.GM_img_bin | output.WM_img_bin | output.CSF_img_bin;
% save masks to file: rtme_util_saveNifti(template_fn, img, new_fn, descrip)
rtme_util_saveNifti(template_vol, output.GM_img_bin, fullfile(preproc_dir, sub, 'anat', [sub '_mask-GM.nii']), 'GM mask')
rtme_util_saveNifti(template_vol, output.WM_img_bin, fullfile(preproc_dir, sub, 'anat', [sub '_mask-WM.nii']), 'WM mask')
rtme_util_saveNifti(template_vol, output.CSF_img_bin, fullfile(preproc_dir, sub, 'anat', [sub '_mask-CSF.nii']), 'CSF mask')
rtme_util_saveNifti(template_vol, output.brain_img_bin, fullfile(preproc_dir, sub, 'anat', [sub '_mask-brain.nii']), 'Brain mask')
% get vector of indices for mask
output.I_brain = find(output.brain_img_bin);
% Determine some descriptive variables
output.N_maskvox = numel(output.I_brain);
% get vectors of indices per tissue type
output.I_GM = find(output.GM_img_bin);
output.I_WM = find(output.WM_img_bin);
output.I_CSF = find(output.CSF_img_bin);
disp('done');