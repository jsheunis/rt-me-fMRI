% fmrwhy_script_neufepDetermineROImetrics

% This script performs the following steps for each run of each task (i.e. * 4):
% 1. Per subject, determine the overlap between the functional task clusters from each echo-timeseries and the anatomical task ROI, write all to file: e.g. 'sub-all_task-motor_run-1_desc-roiOverlap.tsv'
% 2.


%--------------------------------------------------------------------------
settings_fn = '/Users/jheunis/Documents/MATLAB/fMRwhy/code/workflows/fmrwhy_settings_template.m';
options = fmrwhy_defaults();

% -------
% SETUP STEP A -- Check dependencies, Matlab path, etc
% -------
options = fmrwhy_util_checkDependencies(options);

% -------
% SETUP STEP B -- Load settings, defaults, filenames and parameters
% -------
% Run settings file ==> populates study/data-specific fields in the options structure, including BIDS variables
run(settings_fn);

% Setup fmrwhy derivative directories on workflow level
options = fmrwhy_bids_setupQcDerivDirs(options.bids_dir, options);

% Validate settings
options = fmrwhy_settings_validate(options)

options.stats_dir = fullfile(options.bids_dir, 'derivatives', 'fmrwhy-stats');
options.rt_dir = fullfile(options.bids_dir, 'derivatives', 'fmrwhy-rt');


sig_desc = {'RTecho2', 'RTcombinedTSNR', 'RTcombinedT2STAR', 'RTcombinedTE', 'RTcombinedRTt2star', 'RTt2starFIT', 'RTs0FIT'};
roi_desc = {'rleftMotor', 'rbilateralAmygdala', 'rfusiformGyrus', 'FWE', 'noFWE', 'AND', 'OR'};
nfb_sigs = {'raw', 'rawDisp', 'glm', 'kalm', 'scal', 'normPerc', 'nfb', 'nfbDisp'};

echo_colnames = {'echo2', 'combTSNR', 'combT2STAR', 'combTE', 'combT2STARfit', 'T2STARfit'};
cluster_colnames = {'FWE', 'noFWE', 'anatROI', 'fweAND', 'fweOR'};
colnames = {'echo2_FWE', 'echo2_noFWE', 'echo2_anatROI', 'echo2_fweAND', 'echo2_fweOR', 'combTSNR_FWE', 'combTSNR_noFWE', 'combTSNR_anatROI', 'combTSNR_fweAND', 'combTSNR_fweOR', 'combT2STAR_FWE', 'combT2STAR_noFWE', 'combT2STAR_anatROI', 'combT2STAR_fweAND', 'combT2STAR_fweOR', 'combTE_FWE', 'combTE_noFWE', 'combTE_anatROI', 'combTE_fweAND', 'combTE_fweOR', 'combT2STARfit_FWE', 'combT2STARfit_noFWE', 'combT2STARfit_anatROI', 'combT2STARfit_fweAND', 'combT2STARfit_fweOR', 'T2STARfit_FWE', 'T2STARfit_noFWE', 'T2STARfit_anatROI', 'T2STARfit_fweAND', 'T2STARfit_fweOR'};
% regions = sub-011_task-emotionProcessingImagined_desc-rleftMotor_ROIsignals

taskruns = {'fingerTapping', 'fingerTappingImagined', 'emotionProcessing', 'emotionProcessingImagined'};

subs = options.subjects;
% subs = {'001'};

dest_dir = '/Users/jheunis/Documents/Websites/rt-me-fmri-data';
% -------
% PER TASK and RUN
% -------
% Loop through tasks, runs

% /Volumes/My Passport for Mac/NEUFEPME_data_BIDS/derivatives/fmrwhy-rt/sub-011/sub-011_task-emotionProcessingImagined_desc-OR_ROIsignals.tsv
for s = 1:numel(subs)
    sub = subs{s};
    disp(sub);
    for t = 1:numel(taskruns)
        task = taskruns{t};
        disp(['task-' task])
        
        psc_types = {'offline', 'cumulative', 'cumulativebas', 'previousbas'};
        
        for x = 1:numel(psc_types)
            psc_type = psc_types{x};
            subtask_psc_fn = fullfile(options.rt_dir, ['sub-' sub], ['sub-' sub '_task-' task '_desc-realtimeROIsignals_psc' psc_type '.tsv']);
            copyfile(subtask_psc_fn, dest_dir);
        end
    end
end