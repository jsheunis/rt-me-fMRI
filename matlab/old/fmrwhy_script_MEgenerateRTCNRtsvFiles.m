% -------
% STEP 1 -- Load defaults, filenames and parameters
% -------
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
% List me-deriv-dir
options.me_dir = fullfile(options.deriv_dir, 'fmrwhy-multiecho');
options.stats_dir = fullfile(options.deriv_dir, 'fmrwhy-stats');

dash_data_dir = '/Users/jheunis/Documents/Websites/rt-me-fmri-data';

% Load the subjects
subs = options.subjects_output;

tasks = {'fingerTapping', 'emotionProcessing', 'fingerTappingImagined', 'emotionProcessingImagined'};
% tasks = {'fingerTapping'};
% tasks = {'emotionProcessing', 'fingerTappingImagined', 'emotionProcessingImagined'};
echoes = {'2', 'combinedMEtsnr', 'combinedMEt2star', 'combinedMEte', 'combinedMEt2starFIT', 't2starFIT', 's0FIT'};
subs = {'001', '002', '003', '004', '005', '006', '007', '010', '011', '012', '013', '015', '016', '017', '018', '019', '020', '021', '022', '023', '024', '025', '026', '027', '029', '030', '031', '032'};
% subs = {'012', '013', '015', '016', '017', '018', '019', '020', '021', '022', '023', '024', '025', '026', '027', '029', '030', '031', '032'};

% Set subject, sessions
% subs = {'002', '003', '004', '005', '006', '007', '010', '011', '012', '013', '015', '016', '017', '018', '019', '020', '021', '022', '023', '024', '025', '026', '027', '029', '030', '031', '032'};

rtts_colnames = {'RTecho2', 'RTcombinedTSNR', 'RTcombinedT2STAR', 'RTcombinedTE', 'RTcombinedRTt2star', 'RTt2starFIT'};
descs = {'FWE', 'noFWE', 'rleftMotor', 'rbilateralAmygdala', 'rfusiformGyrus', 'AND', 'OR'}
cnr_colnames = {'glm_RTecho2', 'kalm_RTecho2', 'glm_RTcombinedTSNR', 'kalm_RTcombinedTSNR', 'glm_RTcombinedT2STAR', 'kalm_RTcombinedT2STAR', 'glm_RTcombinedTE', 'kalm_RTcombinedTE', 'glm_RTcombinedRTt2star', 'kalm_RTcombinedRTt2star', 'glm_RTt2starFIT', 'kalm_RTt2starFIT', 'glm_RTs0FIT', 'kalm_RTs0FIT'}

for t = 1:numel(tasks)
    task = tasks{t};

    for d = 1:numel(descs)
        desc = descs{d};

        all_cnr_fn = fullfile(options.rt_dir, ['sub-all_task-', task, '_desc-' desc '_ROIcnr.tsv']);
        temp_txt_cnr_fn = strrep(all_cnr_fn, '.tsv', '_temp.txt');
        all_cnr_data = [];
        all_tcnr_fn = fullfile(options.rt_dir, ['sub-all_task-', task, '_desc-' desc '_ROItcnr.tsv']);
        temp_txt_tcnr_fn = strrep(all_tcnr_fn, '.tsv', '_temp.txt');
        all_tcnr_data = [];
        
        for s = 1:numel(subs)
            sub = subs{s};

            cnr_fn = fullfile(options.rt_dir, ['sub-' sub], ['sub-' sub '_task-', task, '_desc-' desc '_ROIcnr.tsv']);
            tcnr_fn = fullfile(options.rt_dir, ['sub-' sub], ['sub-' sub '_task-', task, '_desc-' desc '_ROItcnr.tsv']);
            
            cnr = struct2array(tdfread(cnr_fn));
            tcnr = struct2array(tdfread(tcnr_fn));

            all_cnr_data = [all_cnr_data; cnr];
            all_tcnr_data = [all_tcnr_data; tcnr];

        end

        data_table_cnr = array2table(all_cnr_data,'VariableNames', cnr_colnames);
        writetable(data_table_cnr, temp_txt_cnr_fn, 'Delimiter','\t');
        [status, msg, msgID] = movefile(temp_txt_cnr_fn, all_cnr_fn);
        copyfile(all_cnr_fn, dash_data_dir);

        data_table_tcnr = array2table(all_tcnr_data,'VariableNames', cnr_colnames);
        writetable(data_table_tcnr, temp_txt_tcnr_fn, 'Delimiter','\t');
        [status, msg, msgID] = movefile(temp_txt_tcnr_fn, all_tcnr_fn);
        copyfile(all_tcnr_fn, dash_data_dir);
    end
end

% sub_dir_rt = fullfile(options.rt_dir, ['sub-' sub]);
% files_to_copy = dir(fullfile(sub_dir_rt, '*_ROIpsc.tsv'));
% for i = 1:numel(files_to_copy)
%     copyfile(fullfile(files_to_copy(i).folder, files_to_copy(i).name), dash_data_dir);
% end