% IMPORTANT: these steps are already accounted for in the offlineMEreport script!!!


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

% Directories
options.stats_dir = fullfile(options.bids_dir, 'derivatives', 'fmrwhy-stats');
options.rt_dir = fullfile(options.bids_dir, 'derivatives', 'fmrwhy-rt');
options.me_dir = fullfile(options.bids_dir, 'derivatives', 'fmrwhy-multiecho');
options.dash_dir = fullfile(options.bids_dir, 'derivatives',  'fmrwhy-dash')
options.dash_quality_dir = fullfile(options.dash_dir, 'quality')
options.dash_multiecho_dir = fullfile(options.dash_dir, 'multiecho')

% Tasks
taskruns = {'fingerTapping', 'emotionProcessing', 'rest_run-2' 'fingerTappingImagined', 'emotionProcessingImagined'};

% Set subject, sessions
subs = options.subjects;

for s = 1:numel(subs)
    sub = subs{s};
    ses = '';

    % Update workflow options with subject anatomical derivative filenames
    options = fmrwhy_bids_getAnatDerivs(options.bids_dir, sub, options);

    % load mask
    masks = fmrwhy_util_loadOrientMasks(options.bids_dir, sub, options);
    mask_fn = masks.brain_mask_fn;

    options.sub_dir_me = fullfile(options.me_dir, ['sub-' sub]);
    options.func_dir_me = fullfile(options.sub_dir_me, 'func');

    % Loop through sessions, tasks, runs, etc
    for t = 1:numel(taskruns)

        task = taskruns{t};

        for r = 1:numel(runs)
            run = runs{r};

            disp('------------')
            disp('------------')
            disp(['Task: ' task ';  Run: ' run])
            disp('------------')
            disp('------------')

            % tSNR file for each timeseries
            rafunctional_fn = fullfile(options.func_dir_me, ['sub-' sub '_task-' task '_run-' run '_echo-2_desc-rapreproc_tsnr.nii']);
            combined_t2s_fn = fullfile(options.func_dir_me, ['sub-' sub '_task-' task '_run-' run '_desc-combinedMEt2star_tsnr.nii']);
            combined_tsnr_fn = fullfile(options.func_dir_me, ['sub-' sub '_task-' task '_run-' run '_desc-combinedMEtsnr_tsnr.nii']);
            combined_te_fn = fullfile(options.func_dir_me, ['sub-' sub '_task-' task '_run-' run '_desc-combinedMEte_tsnr.nii']);
            combined_t2sFIT_fn = fullfile(options.func_dir_me, ['sub-' sub '_task-' task '_run-' run '_desc-combinedMEt2starFIT_tsnr.nii']);
            t2sFIT_fn = fullfile(options.func_dir_me, ['sub-' sub '_task-' task '_run-' run '_desc-t2starFIT_tsnr.nii']);
            
            tsnr_fns = {rafunctional_fn, combined_t2s_fn, combined_tsnr_fn, combined_te_fn, combined_t2sFIT_fn, t2sFIT_fn};
            tsnr_output_fns = {};
            for i = 1:numel(tsnr_fns)

                if strcmp(task, 'rest') == 1 && strcmp(run, '1') == 1 && i > 1
                    disp('------------')
                    disp(['... Skipping combined echoes for task: ' task ';  Run: ' run ' ...'])
                    disp('------------')
                    continue;
                end

                [p_tsnr, frm, rg, dim] = fmrwhy_util_readOrientNifti(tsnr_fns{i});
                tsnr_img = p_tsnr.nii.img(:);
    %            fmrwhy_util_calculateTSNR(main_fns{i}, mask_fn, tsnr_fns{i}, template_fn);
                for j = 1:4
                    vals = tsnr_img(masks.([masks.field_names{j} '_mask_I']));
                    tsnr_output_fns{i,j} = strrep(tsnr_fns{i}, '_tsnr.nii', ['_' masks.field_names{j} 'tsnr.tsv']);

                    temp_txt_fn = strrep(tsnr_output_fns{i,j}, '.tsv', '_temp.txt');

                    data_table = array2table(vals,'VariableNames', {'tsnr'});
                    writetable(data_table, temp_txt_fn, 'Delimiter','\t');
                    [status, msg, msgID] = movefile(temp_txt_fn, tsnr_output_fns{i,j});

                    [d,f,e] = fileparts(tsnr_output_fns{i,j});
                    new_fn = fullfile(dash_sub_dir, [f e]);
                    copyfile(tsnr_output_fns{i,j}, new_fn)
                end
            end
        end
    end
end