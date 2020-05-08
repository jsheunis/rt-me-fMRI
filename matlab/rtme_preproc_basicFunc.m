% FUNCTION: rtme_preproc_basicFunc
%--------------------------------------------------------------------------

% Copyright statement....

%--------------------------------------------------------------------------
% DEFINITION
%--------------------------------------------------------------------------
% Function to run basic functional preprocessing steps that are required for
% several subsequent analysis steps.

% STEPS:
% 1. Slice timing correction for:
%   - multi-echo timeseries for rest_run-1 (preparation for parameter estimations)
%   - reference echo timeseries for motor_run-1, emotion_run-1 (preparation for functional localisers)
% 2. Volume realignment for:
%   - multi-echo timeseries for rest_run-1 (preparation for parameter estimations)
%   - reference echo timeseries for motor_run-1, emotion_run-1 (preparation for functional localisers)
% 3. Spatial smoothing for multi-echo timeseries for motor_run-1, emotion_run-1

% QUESTION: should functional localisers also be done based on combined echo data? Perhaps this is worth another research question?



% INPUT:

% OUTPUT:

%--------------------------------------------------------------------------

function output = rtme_preproc_basicFunc(sub, defaults)

% NOTE: Functional template is first volume of rest_run-1

% Load required defaults
spm_dir = defaults.spm_dir;
preproc_dir = defaults.preproc_dir;
template_run = defaults.template_run;
template_task = defaults.template_task;
tasks = defaults.tasks;
template_echo = defaults.template_echo;
N_e = defaults.N_e;
TE = defaults.TE;
N_vol = defaults.N_vol;
TR = defaults.TR;
N_slices = defaults.N_slices;

% Structure to save outputs
output = struct;

% STEP 1: slice timing correction
disp('STEP 1: Slice timing correction')
prefix = 'a';
previous_steps_prefix = '';
for t = 1:numel(tasks)
    for e = 1:N_e
        disp(['Performing slice timing correction for: ' sub '_task-' tasks(t) '_run-' num2str(template_run) '_echo-' num2str(e)])
        functional_fn = fullfile(preproc_dir, sub, 'func', [previous_steps_prefix sub '_task-' tasks(t) '_run-' num2str(template_run) '_echo-' num2str(e) '_bold.nii']);
        sliceTiming = rtme_preproc_sliceTiming(functional_fn, prefix, defaults)
        disp('Complete!')
    end
end

% STEP 2: volume realignment
disp('STEP 2: 3D volume realignment')
prefix = 'r';
previous_steps_prefix = 'a';
run = template_run;
reference_echo = template_echo;
for t = 1:numel(tasks)
    disp(['Performing 3D volume realignment for: ' sub '_task-' tasks(t) '_run-' num2str(template_run)])
    realign = rtme_preproc_realignME(sub, task, run, reference_echo, prefix, previous_steps_prefix, defaults)
    disp('Complete!')
end



% STEP 3: spatial smoothing
disp('STEP 3: Spatial smoothing')
prefix = 's';
previous_steps_prefix = 'ra';
for t = 1:numel(tasks)
    for e = 1:N_e
        disp(['Performing spatial smoothing for: ' sub '_task-' tasks(t) '_run-' num2str(template_run) '_echo-' num2str(e)])
        functional_fn = fullfile(preproc_dir, sub, 'func', [previous_steps_prefix sub '_task-' tasks(t) '_run-' num2str(template_run) '_echo-' num2str(e) '_bold.nii']);
        smooth = rtme_preproc_smooth(functional_fn, prefix, defaults)
        disp('Complete!')
    end
end

