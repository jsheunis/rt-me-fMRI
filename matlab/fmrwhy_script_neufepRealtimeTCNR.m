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
baseline_group = bwlabel(baseline_designPSC);
task_group = bwlabel(task_designPSC);
I_taskPSC = find(task_designPSC);
I_baselinePSC = find(baseline_designPSC);

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

        subtask_sig_fn = fullfile(options.rt_dir, ['sub-' sub], ['sub-' sub '_task-' task '_desc-realtimeROIsignals_raw.tsv']);
        subtask_sig_txt = strrep(subtask_sig_fn, '.tsv', '.txt');
        new_colnames = {};
        new_data = [];

        for d = 1:numel(roi_desc)
            desc = roi_desc{d};
            roi_signals_fn = fullfile(options.rt_dir, ['sub-' sub], ['sub-' sub '_task-' task '_desc-' desc '_ROIsignals.tsv']);
            roi_signals = tdfread(roi_signals_fn);
            for sd = 1:numel(sig_desc)
                s_desc = sig_desc{sd};
                col = ['raw_' s_desc];
                col_data = roi_signals.(col);
                new_col = [s_desc '_' desc];
                
                new_data = [new_data col_data];
                new_colnames = [new_colnames, new_col];
            end
        end
        % Write to tsv file
        data_table = array2table(new_data,'VariableNames', new_colnames);
        writetable(data_table, subtask_sig_txt, 'Delimiter','\t');
        [status, msg, msgID] = movefile(subtask_sig_txt, subtask_sig_fn);


        %-----

        % Calculate PSC in offline way (1):
        offline_detrended = fmrwhy_util_detrend(new_data, 2); %[time, voxels/signals]
        offlinemean = nanmean(offline_detrended); %[1, voxels/signals]
        psc_data_offline = 100*(offline_detrended./offlinemean) - 100;
        psc_data_offline(isnan(psc_data_offline)) = 0;

        % Calculate PSC in various realtime ways:
        psc_data_cumulativemean = nan(size(new_data)); % 2
        cumulativemean = nan(size(new_data)); % 2
        psc_data_cumulativebaselinemean = nan(size(new_data)); % 3
        cumulativebaselinemean = nan(size(new_data)); % 3
        psc_data_prevbaselinemean = nan(size(new_data)); % 4
        prevbaselinemean = nan(size(new_data)); % 4
        
        for i = 1:options.Nscans
            % Remove linear and quadratic trend per voxel
            data_2D_detrended = fmrwhy_util_detrend(new_data(1:i,:), 2); %[time, voxels/signals]

            % Cumulative
            cumulativemean(i,:) = nanmean(data_2D_detrended); %[1, voxels/signals]
            psc_data_cumulativemean(i,:) = 100*(data_2D_detrended(i,:)./cumulativemean(i,:)) - 100;
            psc_data_cumulativemean(isnan(psc_data_cumulativemean)) = 0;

            % Cumulative baseline
            i_bas = I_baselinePSC(I_baselinePSC<i);
            cumulativebaselinemean(i,:) = nanmean(data_2D_detrended(i_bas,:)); %[1, voxels/signals]
            psc_data_cumulativebaselinemean(i,:) = 100*(data_2D_detrended(i,:)./cumulativebaselinemean(i,:)) - 100;
            psc_data_cumulativebaselinemean(isnan(psc_data_cumulativebaselinemean)) = 0;

            % previous baseline
            if task_designPSC(i) == 1
                N_group = task_group(i);
                i_prevbaseline = find(baseline_group==N_group);
                prevbaselinemean(i,:) = nanmean(data_2D_detrended(i_prevbaseline,:)); %[1, voxels/signals]
                psc_data_prevbaselinemean(i,:) = 100*(data_2D_detrended(i,:)./prevbaselinemean(i,:)) - 100;
                psc_data_prevbaselinemean(isnan(psc_data_prevbaselinemean)) = 0;
            else
                psc_data_prevbaselinemean(i,:) = 0;
            end

        end

        psc_types = {'offline', 'cumulative', 'cumulativebas', 'previousbas'};
        psc_data = {psc_data_offline, psc_data_cumulativemean, psc_data_cumulativebaselinemean, psc_data_prevbaselinemean};
        for x = 1:numel(psc_types)
            psc_type = psc_types{x};
            subtask_psc_fn = fullfile(options.rt_dir, ['sub-' sub], ['sub-' sub '_task-' task '_desc-realtimeROIsignals_psc' psc_type '.tsv']);
            subtask_psc_txt = strrep(subtask_psc_fn, '.tsv', '.txt');
            data_table = array2table(psc_data{x},'VariableNames', new_colnames);
            writetable(data_table, subtask_psc_txt, 'Delimiter','\t');
            [status, msg, msgID] = movefile(subtask_psc_txt, subtask_psc_fn);
        end

    end
end


psc_types = {'offline', 'cumulative', 'cumulativebas', 'previousbas'};

for t = 1:numel(taskruns)
    task = taskruns{t};

    disp(['task-' task])

    for x = 1:numel(psc_types)
        psc_type = psc_types{x};
        cnr_mat = nan(numel(subs), numel(new_colnames));
        tcnr_mat = nan(numel(subs), numel(new_colnames));

        for s = 1:numel(subs)
            sub = subs{s};
            disp(sub)

            % grab timeseries_fn
            psc_timeseries_fn = fullfile(options.rt_dir, ['sub-' sub], ['sub-' sub '_task-' task '_desc-realtimeROIsignals_psc' psc_type '.tsv']);
            psc_timeseries = struct2array(tdfread(psc_timeseries_fn));

            cnr = nanmean(psc_timeseries(I_taskPSC,:), 1) - nanmean(psc_timeseries(I_baselinePSC, :), 1);
            tcnr = cnr./std(psc_timeseries, 0, 1);

            cnr_mat(s, :) = cnr;
            tcnr_mat(s, :) = tcnr;

        end
        % Initialize file and matrix for roi overlap data
        cnr_all_fn = fullfile(options.rt_dir, ['sub-all_task-' task '_desc-realtimeROIcnr_' psc_type '.tsv']);
        tcnr_all_fn = fullfile(options.rt_dir, ['sub-all_task-' task '_desc-realtimeROItcnr_' psc_type '.tsv']);

        [d, f, e] = fileparts(cnr_all_fn);
        temp_cnr_fn = fullfile(d, [f '.txt']);
        [d, f, e] = fileparts(tcnr_all_fn);
        temp_tcnr_fn = fullfile(d, [f '.txt']);

        % Write CNR to tsv file
        data_table = array2table(cnr_mat,'VariableNames', new_colnames);
        writetable(data_table, temp_cnr_fn, 'Delimiter','\t');
        [status, msg, msgID] = movefile(temp_cnr_fn, cnr_all_fn);

        % Write tCNR to tsv file
        data_table = array2table(tcnr_mat,'VariableNames', new_colnames);
        writetable(data_table, temp_tcnr_fn, 'Delimiter','\t');
        [status, msg, msgID] = movefile(temp_tcnr_fn, tcnr_all_fn);
        
    end
end