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
% Load the subjects
subs = options.subjects_output;


for s = 1:numel(subs)
    sub = subs{s};
    options = fmrwhy_bids_getAnatDerivs(options.bids_dir, sub, options);

    qcsub_dir = fullfile(options.qc_dir, ['sub-' sub]);
    dir_contents = dir(qcsub_dir);
    for i = 1:numel(dir_contents)
        if (dir_contents(i).isdir == 1) && contains(dir_contents(i).name, 'report')
            rmdir(fullfile(qcsub_dir, dir_contents(i).name), 's');
        end
    end

    fmrwhy_bids_qcSubReport(sub, options);

end