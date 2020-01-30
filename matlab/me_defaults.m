% File/directory locations

matlab_dir = '/Users/jheunis/Documents/MATLAB'; % Specify MATLAB code directory
spm_dir = '/Users/jheunis/Documents/MATLAB/spm12'; % Specify SPM installation directory
deriv_dir = '/Volumes/Stephan_WD/NEUFEPME_data_BIDS_derivatives'; % Specify processing directory

% Data setup








% % --- For OpenNFT sample data --- %
% data_dir = '/Users/jheunis/Desktop/All/Code and data tests/neu3carttest'; % Specify parent directory that contains all data
% sub_dir = [data_dir filesep 'sub-opennft']; % Specify specific subject directory
% functional0_fn      =   [sub_dir filesep 'template_func.nii']; % Functional template from pre-real-time scan
% structural_fn = [sub_dir filesep 'structScan_PSC.nii']; % Structural scan, from pre-real-time
% ROI_native = true; % are ROIs already in native space with matching resolution?
% N_RNOIs = 5; % Reference ROIs: 1-GM, 2-WM, 3-CSF, 4-masked brain (=GM+WM+CSF), 5-background slice/region
% N_ROIs = 2+N_RNOIs; % number of ROIs supplied + N_RNOIs
% ROI_fns = cell(1,N_ROIs);
% ROI_fns{1} = [sub_dir filesep 'lROI_1.nii'];
% ROI_fns{2} = [sub_dir filesep 'rROI_2.nii'];
% Ne = 1; % number of EPI echoes
% voxel_size = [2.973 2.973 3.75];
% smoothing_kernel    = [6 6 6];
% Nt =   155; % NrOfVolumes % VolumesNumber
% N_skip = 5; % nrSkipVol
% N_start = N_skip + 1;
% Ndyn = Nt - N_skip;
% TR = 2;
% TR_skip = 2; % amount of TRs to skip at start of baseline block to exclude effect of HRF on baseline mean calculation
% NF_cond = 2; % location of task/nf condition in design matrix (in SPM.mat structure)
% lCond = 2; % number of conditions (should actually be derived form SPM.mat)
% timing_units = 'scans';
% task_onsets = [11; 31; 51; 71; 91; 111; 131]; % onsets (in scan number) of task blocks in experimental paradigm
% task_durations = [10; 10; 10; 10; 10; 10; 10];
% baseline_onsets = [1; 21; 41; 61; 81; 101; 121; 141];
% baseline_durations = [10; 10; 10; 10; 10; 10; 10; 10];
% Nslice = 17;
% rotateDir = [0 0 1];
% rotateVal = 1;
% rotateDeg = 270;
% showMontage = true;