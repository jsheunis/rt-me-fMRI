% ---------------------- %
% Main NEUFEP-ME real-time processing script
% ---------------------- %

% TODO: NOTE - EVERYTHING IS READ IN AND SAVED WITH SPM_VOL (ETC) AND NOT USING NII_TOOL


settings_fn = '/Users/jheunis/Documents/PYTHON/rtme-fMRI/matlab/fmrwhy_settings_RTME.m';
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

% Create derivatives directory for rt output
options.rt_dir = fullfile(options.deriv_dir, 'fmrwhy-rt');
if ~exist(options.rt_dir, 'dir')
    mkdir(options.rt_dir);
end
% List me-deriv-dir
options.me_dir = fullfile(options.deriv_dir, 'fmrwhy-multiecho');

% Load the subjects
subs = options.subjects_output;

tasks = {'fingerTapping', 'emotionProcessing', 'fingerTappingImagined', 'emotionProcessingImagined'};
% tasks = {'fingerTapping'};
% tasks = {'emotionProcessing', 'fingerTappingImagined', 'emotionProcessingImagined'};
echoes = {'2', 'combinedMEtsnr', 'combinedMEt2star', 'combinedMEte', 'combinedMEt2starFIT', 't2starFIT', 's0FIT'};
% subs = {'002', '003', '004', '005', '006', '007', '010'}; %'011', '012', '013', '015', '016', '017', '018', '019', '020', '021', '022', '023', '024', '025', '026', '027', '029', '030', '031', '032'};
% subs = {'012', '013', '015', '016', '017', '018', '019', '020', '021', '022', '023', '024', '025', '026', '027', '029', '030', '031', '032'};
subs = {'011'};
tasks = {'emotionProcessingImagined'};
ses = '';
echo = echoes{1};

% -------
% STEP 2: fMRwhy setup
% -------


for s = 1:numel(subs)

    clearvars -except bids_dir tasks runs echoes subs ses echo s options

    sub = subs{s};

    % Update workflow options with subject anatomical derivative filenames
    options = fmrwhy_bids_getAnatDerivs(options.bids_dir, sub, options);

    % Multi-echo derivative dir
    options.sub_dir_me = fullfile(options.me_dir, ['sub-' sub]);
    options.stats_dir = fullfile(options.deriv_dir, 'fmrwhy-stats');
    
    % Create sub directory for rt output
    options.sub_dir_rt = fullfile(options.rt_dir, ['sub-' sub]);
    if ~exist(options.sub_dir_rt, 'dir')
        mkdir(options.sub_dir_rt);
    end    

    % Get template
    [filename, filepath] = fmrwhy_bids_constructFilename('func', 'sub', sub, 'task', options.template_task, 'run', options.template_run, 'space', 'individual', 'ext', '_bold.nii');
    template_fn = fullfile(options.preproc_dir, filepath, filename);
    options.template_fn = template_fn;

    % Map the fusiform gurys to subject functional space
    disp('map-fusiform-gyrus')
    roi_fn =  fullfile(options.preproc_dir, ['sub-' sub], 'anat', ['sub-' sub '_space-individual_desc-rfusiformGyrus_roi.nii']);
    if ~exist(roi_fn, 'file')
        fmrwhy_preproc_anatLocaliser(sub, options);
    end

    % For each task, run real-time pipeline
    for t = 1:numel(tasks)
        task = tasks{t};

        disp('-----------------------------------------------------')
        disp(['Running RT analysis for: sub-' sub '_task-' task])
        disp('-----------------------------------------------------')

        % Update workflow params with subject functional derivative filenames
        % options = fmrwhy_defaults_subFunc(bids_dir, sub, ses, task, run, echo, options);

        disp('rtme-init')
        fmrwhy_script_rtme_initShort;
        disp('rtme-script')
        fmrwhy_script_rtmeShort;
        disp('rtme-postprocess')
        fmrwhy_script_rtme_postprocessShort;
    end
end
