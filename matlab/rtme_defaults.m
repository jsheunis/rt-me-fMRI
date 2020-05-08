% Initialise data structure
defaults = struct;

% Directories
defaults.matlab_dir = '/Users/jheunis/Documents/MATLAB'; % Specify MATLAB code directory
defaults.spm_dir = '/Users/jheunis/Documents/MATLAB/spm12'; % Specify SPM installation directory
defaults.bids_dir = '/Volumes/Stephan_WD/NEUFEPME_data_BIDS'; % Specify processing directory
defaults.deriv_dir = '/Volumes/Stephan_WD/NEUFEPME_data_BIDS_derivatives'; % Specify processing directory
defaults.preproc_dir = fullfile(defaults.deriv_dir, 'SPM12preproc');
defaults.template_dir = '/Volumes/Stephan_WD/NEUFEPME_data_templates'; % Specify processing directory

% Study and analysis parameters
defaults.tasks = ['rest', 'motor', 'emotion'];
defaults.template_task = 'rest';
defaults.template_run = 1;
defaults.template_echo = 2;
defaults.N_ROIs = 2;

% Template files
defaults.ROI_fns = cell(1,N_ROIs);
defaults.ROI_fns{1} = fullfile(defaults.template_dir, 'Left_Motor_4a_4p.nii.gz');
defaults.ROI_fns{2} = fullfile(defaults.template_dir, 'Bilateral_Amygdala_allregions.nii.gz');

% Scanning parameters
defaults.N_e = 3; % number of echoes per volume
defaults.TE = [14 28 42]; % Echo times in ms
defaults.N_slices = 34;

defaults.voxel_size = [3.5 3.5 3.5];
defaults.smoothing_kernel    = [7 7 7];
defaults.N_t =   210; % NrOfVolumes % VolumesNumber
defaults.N_skip = 0; % nrSkipVol
defaults.N_start = N_skip + 1;
defaults.N_dyn = N_t - N_skip;
defaults.TR = 2;
defaults.TR_skip = 2; % amount of TRs to skip at start of baseline block to exclude effect of HRF on baseline mean calculation
defaults.NF_cond = 2; % location of task/nf condition in design matrix (SPM structure)


%% For basicFunc.m
% Preprocessed file naming conventions
defaults.stc_prefix = 'a';
defaults.realign_prefix = 'r';
defaults.smooth_prefix = 's';
defaults.FD_threshold = 0.5;


%% For funcLocaliser.m




%% For estimateParams.m
% T2star_thresh = 100; % threshold for maximum T2star after estimation


% lCond = 2; % number of conditions (should actually be derived form SPM mat)
% task_onsets = [17; 49; 81; 113; 145; 177];
% task_durations = [16; 16; 16; 16; 16; 16];
% baseline_onsets = [1; 33; 65; 97; 129; 161; 193];
% baseline_durations = [16; 16; 16; 16; 16; 16; 16];

% Data setup
% TODO: figure out which sections of the JuBrain template ROIs to use in each task


