% FUNCTION: rtme_preproc_funcLocaliser
%--------------------------------------------------------------------------

% Copyright statement....

%--------------------------------------------------------------------------
% DEFINITION
%--------------------------------------------------------------------------
% Function to run steps for functional localisation of task-related region

% STEPS:
%    1. Slice time correction (basicFunc.m)
%    2. 3D volume realignment (basicFunc.m)
%    3. Calculate framewise displacement from realignment params, select outliers using FD threshold (*which value or percentage?*)
%    4. Gaussian kernel smoothing (2*voxel size?)
%    5. GLM analysis incl:
%        1. AR(1) autoregressive filtering
%        2. Drift removal / high-pass (SPM cosine basis set)
%        3. Realignment params [+expansion?]
%        4. RETROICOR (+HRV, RTV?)
%        5. FD outlier binary regressor
%        6. *(global or tissue compartment signals???)*
%    6. Select t-stat peak within anatomically bound mask (from anatomy toolbox ROI)
%    7. Select N amount of voxels neighbouring peak voxel ==> ROI for real-time use

% INPUT:

% OUTPUT:

%--------------------------------------------------------------------------

function output = rtme_preproc_funcLocaliser(sub, task, run, echo, defaults)

% Load required defaults
spm_dir = defaults.spm_dir;
preproc_dir = defaults.preproc_dir;
template_run = defaults.template_run;
template_task = defaults.template_task;
template_echo = defaults.template_echo;
stc_prefix = defaults.stc_prefix;
realign_prefix = defaults.realign_prefix;
smooth_prefix = defaults.smooth_prefix;
tasks = defaults.tasks

% Grab files for preprocessing
% (Functional template is first volume of rest_run-1)
template_vol = fullfile(preproc_dir, sub, 'func', [sub '_task-' template_task '_run-' num2str(template_run) '_echo-' num2str(emplate_echo) '_bold_template.nii']);
structural_fn = fullfile(preproc_dir, sub, 'anat', [sub '_T1w.nii']);

% Structure to save outputs
output = struct;

% Step 1. Slice time correction - done in basicFunc.m
afunctional_fn = fullfile(preproc_dir, sub, 'func', [stc_prefix sub '_task-' tasks(task) '_run-' num2str(run) '_echo-' num2str(echo) '_bold.nii']);

% Step 2. 3D volume realignment - done in basicFunc.m
rafunctional_fn = fullfile(preproc_dir, sub, 'func', [realign_prefix stc_prefix sub '_task-' tasks(task) '_run-' num2str(run) '_echo-' num2str(echo) '_bold.nii']);

% Step 3. Gaussian kernel smoothing - done in basicFunc.m
srafunctional_fn = fullfile(preproc_dir, sub, 'func', [smooth_prefix realign_prefix stc_prefix sub '_task-' tasks(task) '_run-' num2str(run) '_echo-' num2str(echo) '_bold.nii']);

% Step 4.   Calculate framewise displacement from realignment params;
%           select outliers using FD threshold (*which value or percentage?*) see FSL? percentile?
