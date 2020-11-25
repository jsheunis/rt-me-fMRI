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



echo_colnames = {'echo2', 'combTSNR', 'combT2STAR', 'combTE', 'combT2STARfit', 'T2STARfit'};
cluster_colnames = {'FWE', 'noFWE', 'anatROI', 'fweAND', 'fweOR'};
colnames = {'echo2_FWE', 'echo2_noFWE', 'echo2_anatROI', 'echo2_fweAND', 'echo2_fweOR', 'combTSNR_FWE', 'combTSNR_noFWE', 'combTSNR_anatROI', 'combTSNR_fweAND', 'combTSNR_fweOR', 'combT2STAR_FWE', 'combT2STAR_noFWE', 'combT2STAR_anatROI', 'combT2STAR_fweAND', 'combT2STAR_fweOR', 'combTE_FWE', 'combTE_noFWE', 'combTE_anatROI', 'combTE_fweAND', 'combTE_fweOR', 'combT2STARfit_FWE', 'combT2STARfit_noFWE', 'combT2STARfit_anatROI', 'combT2STARfit_fweAND', 'combT2STARfit_fweOR', 'T2STARfit_FWE', 'T2STARfit_noFWE', 'T2STARfit_anatROI', 'T2STARfit_fweAND', 'T2STARfit_fweOR'}

taskruns = {'fingerTapping', 'fingerTappingImagined', 'emotionProcessing', 'emotionProcessingImagined'};
% /Volumes/My Passport for Mac/NEUFEPME_data_BIDS/derivatives/fmrwhy-stats/sub-005_task-emotionProcessingImagined_desc-PSCvalues.tsv
% sub-005_task-fingerTappingImagined_desc-PSCtimeseries

subs = options.subjects;

task_onsetsPSC = [13; 33; 53; 73; 93; 113; 133; 153; 173; 193];
task_durationsPSC = [8; 8; 8; 8; 8; 8; 8; 8; 8; 8];
task_designPSC = zeros(1, options.Nscans);
for n = 1:length(task_onsetsPSC)
    for m = task_onsetsPSC(n):(task_onsetsPSC(n)+task_durationsPSC(n)-1)
        task_designPSC(m) = 1;
    end
end
% task_designPSC = [task_designPSC zeros(1,10)];
baseline_designPSC = ~task_designPSC;
I_taskPSC = find(task_designPSC);
I_baselinePSC = find(baseline_designPSC);

% -------
% PER TASK and RUN
% -------
% Loop through tasks, runs
for t = 1:numel(taskruns)
    task = taskruns{t};

    disp(['task-' task])

    % Initialize file and matrix for roi overlap data
    cnr_all_fn = fullfile(options.stats_dir, ['sub-all_task-' task '_desc-offlineROIcnr.tsv']);
    tcnr_all_fn = fullfile(options.stats_dir, ['sub-all_task-' task '_desc-offlineROItcnr.tsv']);

    [d, f, e] = fileparts(cnr_all_fn);
    temp_cnr_fn = fullfile(d, [f '.txt']);
    [d, f, e] = fileparts(tcnr_all_fn);
    temp_tcnr_fn = fullfile(d, [f '.txt']);


    cnr_mat = nan(numel(subs), numel(colnames));
    tcnr_mat = nan(numel(subs), numel(colnames));


    for s = 1:numel(subs)
        sub = subs{s};
        disp(sub)

        % grab timeseries_fn
        psc_timeseries_fn = fullfile(options.stats_dir, ['sub-' sub '_task-' task '_desc-PSCtimeseries.tsv']);
        psc_timeseries = struct2array(tdfread(psc_timeseries_fn));

        cnr = nanmean(psc_timeseries(I_taskPSC,:), 1) - nanmean(psc_timeseries(I_baselinePSC, :), 1);
        tcnr = cnr./std(psc_timeseries, 0, 1);

        cnr_mat(s, :) = cnr;
        tcnr_mat(s, :) = tcnr;

    end

    % Write CNR to tsv file
    data_table = array2table(cnr_mat,'VariableNames', colnames);
    writetable(data_table, temp_cnr_fn, 'Delimiter','\t');
    [status, msg, msgID] = movefile(temp_cnr_fn, cnr_all_fn);

    % Write tCNR to tsv file
    data_table = array2table(tcnr_mat,'VariableNames', colnames);
    writetable(data_table, temp_tcnr_fn, 'Delimiter','\t');
    [status, msg, msgID] = movefile(temp_tcnr_fn, tcnr_all_fn);
end