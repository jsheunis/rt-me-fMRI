% fmrwhy_script_neufepDecayTests

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
options.me_dir = fullfile(options.bids_dir, 'derivatives', 'fmrwhy-multiecho');


sig_desc = {'RTecho2', 'RTcombinedTSNR', 'RTcombinedT2STAR', 'RTcombinedTE', 'RTcombinedRTt2star', 'RTt2starFIT', 'RTs0FIT'};
roi_desc = {'rleftMotor', 'rbilateralAmygdala', 'rfusiformGyrus', 'FWE', 'noFWE', 'AND', 'OR'};
nfb_sigs = {'raw', 'rawDisp', 'glm', 'kalm', 'scal', 'normPerc', 'nfb', 'nfbDisp'};

echo_colnames = {'echo2', 'combTSNR', 'combT2STAR', 'combTE', 'combT2STARfit', 'T2STARfit'};
cluster_colnames = {'FWE', 'noFWE', 'anatROI', 'fweAND', 'fweOR'};
colnames = {'echo2_FWE', 'echo2_noFWE', 'echo2_anatROI', 'echo2_fweAND', 'echo2_fweOR', 'combTSNR_FWE', 'combTSNR_noFWE', 'combTSNR_anatROI', 'combTSNR_fweAND', 'combTSNR_fweOR', 'combT2STAR_FWE', 'combT2STAR_noFWE', 'combT2STAR_anatROI', 'combT2STAR_fweAND', 'combT2STAR_fweOR', 'combTE_FWE', 'combTE_noFWE', 'combTE_anatROI', 'combTE_fweAND', 'combTE_fweOR', 'combT2STARfit_FWE', 'combT2STARfit_noFWE', 'combT2STARfit_anatROI', 'combT2STARfit_fweAND', 'combT2STARfit_fweOR', 'T2STARfit_FWE', 'T2STARfit_noFWE', 'T2STARfit_anatROI', 'T2STARfit_fweAND', 'T2STARfit_fweOR'};
% regions = sub-011_task-emotionProcessingImagined_desc-rleftMotor_ROIsignals

taskruns = {'fingerTapping', 'fingerTappingImagined', 'emotionProcessing', 'emotionProcessingImagined'};

subs = options.subjects;
subs = {'001'};

% task_onsetsPSC = [13; 33; 53; 73; 93; 113; 133; 153; 173; 193];
% task_durationsPSC = [8; 8; 8; 8; 8; 8; 8; 8; 8; 8];
% task_designPSC = zeros(1, options.Nscans);
% for n = 1:length(task_onsetsPSC)
%     for m = task_onsetsPSC(n):(task_onsetsPSC(n)+task_durationsPSC(n)-1)
%         task_designPSC(m) = 1;
%     end
% end
% % task_designPSC = [task_designPSC zeros(1,10)];
% baseline_designPSC = ~task_designPSC;
% baseline_group = bwlabel(baseline_designPSC);
% task_group = bwlabel(task_designPSC);
% I_taskPSC = find(task_designPSC);
% I_baselinePSC = find(baseline_designPSC);

TE = [14, 28, 42];
Nt = 210;
% -------
% PER TASK and RUN
% -------
% Loop through tasks, runs
for s = 1:numel(subs)
    sub = subs{s};
    disp(sub);

    % load template
    template_fn = fullfile(options.preproc_dir, ['sub-' sub], 'func', ['sub-' sub '_task-' options.template_task '_run-' options.template_run '_space-individual_bold.nii']);
    nii_template = nii_tool('load', template_fn);
    img_template = double(nii_template.img);
    [Ni, Nj, Nk] = size(img_template);
    Nvox = Ni*Nj*Nk;
    % load echos and ME params
    e1_fn = fullfile(options.preproc_dir, ['sub-' sub], 'func', ['sub-' sub '_task-rest_run-1_echo-1_desc-rapreproc_bold.nii']);
    e2_fn = fullfile(options.preproc_dir, ['sub-' sub], 'func', ['sub-' sub '_task-rest_run-1_echo-2_desc-rapreproc_bold.nii']);
    e3_fn = fullfile(options.preproc_dir, ['sub-' sub], 'func', ['sub-' sub '_task-rest_run-1_echo-3_desc-rapreproc_bold.nii']);
    t2star_fn = fullfile(options.me_dir, ['sub-' sub], 'func', ['sub-' sub '_task-rest_run-1_desc-MEparams_t2star.nii']);
    s0_fn = fullfile(options.me_dir, ['sub-' sub], 'func', ['sub-' sub '_task-rest_run-1_desc-MEparams_s0.nii']);

    fns = {e1_fn, e2_fn, e3_fn, t2star_fn, s0_fn};
    nii = {};
    img_vals = {};
    echos_params = [];

    for i = 1:numel(fns)
        nii{i} = nii_tool('load', fns{i});
        if i < 4
            data_4D = double(nii{i}.img); % [Ni x Nj x Nk x Nt]
            % Reshape to 2D matrix of time x voxels
            data_2D = reshape(data_4D, Nvox, Nt); %[voxels, time]
            data_2D = data_2D'; %[time, voxels]
            % Remove linear and quadratic trends from data, per voxel
            data_2D_detrended = fmrwhy_util_detrend(data_2D, 2); %[time, voxels]
            % Calculate timeseries mean per voxel (ignoring NaN)
            data_mean = nanmean(data_2D_detrended); %[1, voxels]
            img_vals_reshaped{i} = data_mean'; %[voxels, 1]
        else
            data_3D = double(nii{i}.img); % [Ni x Nj x Nk]
            img_vals_reshaped{i} = reshape(data_3D, Nvox, 1);
        end
        echos_params = [echos_params img_vals_reshaped{i}];
    end

    % Load masks
    masks = fmrwhy_util_loadMasks(options.bids_dir, sub, options);

    % Calculate sum of squared error
    S_actual = echos_params(:,1:3);
    S_hat = echos_params(:,5).*exp(-TE./echos_params(:,4)); % S = S0*exp(-t/t2star)
    S_sqerror = (S_actual - S_hat).^2;
    S_sqerrorsum = sum(S_sqerror, 2);
    S_sqerrorsum_masked = zeros(size(S_sqerrorsum));
    S_sqerrorsum_masked(masks.GM_mask_I) = S_sqerrorsum(masks.GM_mask_I);
    
    % Save summ of squared error as nii
    error_img = reshape(S_sqerrorsum_masked, Ni, Nj, Nk);
    error_img_fn = fullfile(options.me_dir, ['sub-' sub], 'func', ['sub-' sub '_task-rest_run-1_desc-MEparams_sserror.nii']);
    no_scaling = 1;
    % fmrwhy_util_saveNifti(error_img_fn, error_img, template_fn, no_scaling);

    % load ROIs
    roi_lmotor_fn = fullfile(options.preproc_dir, ['sub-' sub], 'anat', ['sub-' sub '_space-individual_desc-rleftMotor_roi.nii']);
    roi_bamygdala_fn = fullfile(options.preproc_dir, ['sub-' sub], 'anat', ['sub-' sub '_space-individual_desc-rBilateralAmygdala_roi.nii']);
    roi_fns = {roi_lmotor_fn, roi_bamygdala_fn};
    roi_names = {'motor', 'amygdala', 'GM', 'WM', 'CSF'};
    roi_img = {};
    I_roi = {};
    for i = 1:numel(roi_fns)
        nii = nii_tool('load', roi_fns{i});
        roi_img{i} = fmrwhy_util_createBinaryImg(double(nii.img), 0.1);
        roi_img_2D{i} = reshape(roi_img{i}, Nvox, 1);
        I_roi{i} = find(masks.GM_mask_2D & roi_img_2D{i});
    end
    I_roi{3} = masks.GM_mask_I;
    I_roi{4} = masks.WM_mask_I;
    I_roi{5} = masks.CSF_mask_I;

    % Calculate mean parameters per ROI
    mean_t2star = {};
    mean_s0 = {};
    t2star_2D = echos_params(:,4);
    s0_2D = echos_params(:,5);
    for i = 1:numel(I_roi)
        mean_t2star{i} = nanmean(t2star_2D(I_roi{i}));
        mean_s0{i} = nanmean(s0_2D(I_roi{i}));
        

        % figure;
        % t = linspace(0,100,100);
        % x = mean_s0{i}*exp(-t./mean_t2star{i});
        % plot(t,x); hold on;
        % plot(TE, nanmean(S_hat(I_roi{i}, :), 1), 'bo');
        % plot(TE, nanmean(S_actual(I_roi{i}, :), 1), 'rx'); hold off;
        % title(roi_names{i});

    end
    
    


end


% psc_types = {'offline', 'cumulative', 'cumulativebas', 'previousbas'};

% for t = 1:numel(taskruns)
%     task = taskruns{t};

%     disp(['task-' task])

%     for x = 1:numel(psc_types)
%         psc_type = psc_types{x};
%         cnr_mat = nan(numel(subs), numel(new_colnames));
%         tcnr_mat = nan(numel(subs), numel(new_colnames));

%         for s = 1:numel(subs)
%             sub = subs{s};
%             disp(sub)

%             % grab timeseries_fn
%             psc_timeseries_fn = fullfile(options.rt_dir, ['sub-' sub], ['sub-' sub '_task-' task '_desc-realtimeROIsignals_psc' psc_type '.tsv']);
%             psc_timeseries = struct2array(tdfread(psc_timeseries_fn));

%             cnr = nanmean(psc_timeseries(I_taskPSC,:), 1) - nanmean(psc_timeseries(I_baselinePSC, :), 1);
%             tcnr = cnr./std(psc_timeseries, 0, 1);

%             cnr_mat(s, :) = cnr;
%             tcnr_mat(s, :) = tcnr;

%         end
%         % Initialize file and matrix for roi overlap data
%         cnr_all_fn = fullfile(options.rt_dir, ['sub-all_task-' task '_desc-realtimeROIcnr_' psc_type '.tsv']);
%         tcnr_all_fn = fullfile(options.rt_dir, ['sub-all_task-' task '_desc-realtimeROItcnr_' psc_type '.tsv']);

%         [d, f, e] = fileparts(cnr_all_fn);
%         temp_cnr_fn = fullfile(d, [f '.txt']);
%         [d, f, e] = fileparts(tcnr_all_fn);
%         temp_tcnr_fn = fullfile(d, [f '.txt']);

%         % Write CNR to tsv file
%         data_table = array2table(cnr_mat,'VariableNames', new_colnames);
%         writetable(data_table, temp_cnr_fn, 'Delimiter','\t');
%         [status, msg, msgID] = movefile(temp_cnr_fn, cnr_all_fn);

%         % Write tCNR to tsv file
%         data_table = array2table(tcnr_mat,'VariableNames', new_colnames);
%         writetable(data_table, temp_tcnr_fn, 'Delimiter','\t');
%         [status, msg, msgID] = movefile(temp_tcnr_fn, tcnr_all_fn);
        
%     end
% end