%% rt-me-fmri_reproduce_matlabProcessing.m

% This is the main script detailing the order in which all data were processed,
% and providing the code and instructions with which to do so.
% This script is not meant to be executed fully as a standalone script,
% rather each step should be done individually, manually, and chronologically.
% This script is preceded by data preparation scripts (see relevant jupyter notebook)
% This script requires fMRwhy and its dependencies to be installed


% -------
% -------
% Setings
% -------
% -------

% A settings file is required with prefilled details pertaining to the dataset and analysis
% see fmrwhy_settings_rtmefMRI.m in this repo
settings_fn = '<...>/matlab/fmrwhy_settings_rtmefMRI.m';


% ------------------------------
% ------------------------------
% Preprocessing and data quality
% ------------------------------
% ------------------------------

% Run minimal preprocessing steps and data quality processing
% see fmrwhy_bids_workflowQC in fMRwhy
fmrwhy_bids_workflowQC(settings_fn);


% ------------------------------
% ------------------------------
% Multi-echo processing pipeline
% ------------------------------
% ------------------------------

% ----------------------------------
% STEP 1 - fmrwhy_workflow_offlineME
% ----------------------------------
% 1.1)  Create functional template, if it does not exist
% 1.2)  For all tasks and runs, complete minimal preprocessing for multi-echo combination
% 1.3)  Run template process on specific task and run predefined the multi-echo template
%       - Calculate tSNR per echo, using the slice time corrected and realigned functional timeseries
%       - Calculate/estimate T2star and S0 maps
% 1.4)  Run combination process on all tasks and runs except for the template
%       - Prepare template data and run multi-echo combination functions
%       - Prepare template data and run FIT multi-echo combination
% 1.5)  Calculate tSNR for each combined timeseries
% 1.6)  Smooth each combined timeseries, for later analysis purposes
fmrwhy_workflow_offlineME;

% ----------------------------------------
% STEP 2 - fmrwhy_workflow_offlineMEreport
% ----------------------------------------
% 2.1)  Visualise T2star and S0 maps
% 2.2)  For all tasks and runs, generate ME-related images for all six time series:
%       - For template task and run, visualise bold and tSNR data
%       - For other, visualise: bold data, tSNR data
%       - Create tSNR comparison outputs: fmrwhy_util_compareTSNRrt
%       - Carpet plots for ROIs (fmrwhy_util_thePlotROI)
% 2.3)  Normalise all tSNR images to MNI: fmrwhy_batch_normaliseWrite
% 2.4)  Delineate tSNR values per tissue type and ROI ==> output TSV files
fmrwhy_workflow_offlineMEreport;
rtme_script_generateMEtSNRtsvFiles; % (need to check if this is necessary, perhaps does stuff thats already incorporated into fmrwhy_workflow_offlineMEreport)

% ---------------------------------
% STEP 3 - Subject level statistical analysis
% ---------------------------------
% 3.1)  1st level analysis for all task runs, for all time series
%       - fmrwhy_workflow_1stlevelRun:
%           - GLM, contrasts, run model; FWE, k=0, p<0.05
%           - T-map montages
%           - Calculate anatomical-functional overlap ROI
%       - Transform T-maps to MNI
% 3.2)  Redo above, but with different statistical threshold (no FWE, k=20, p<0.001)
%       - fmrwhy_script_newThreshold1stlevel;
fmrwhy_workflow_1stlevel;
fmrwhy_script_newThreshold1stlevel;

% -------------------------------------------
% STEP 4 - Extract and write data for results
% -------------------------------------------
% For all subs, for each task run, for all time series per task run:
% 4.1)  fmrwhy_script_neufepDetermineROImetrics, writes results to TSV files in "derivatives/fmrwhy-stats" directory:
%       - sub-X_task-Y_desc-PSCvalues.tsv
%       - sub-X_task-Y_desc-cmapvalues.tsv
%       - sub-X_task-Y_desc-tmapvalues.tsv
%       - sub-X_task-Y_desc-PSCtimeseries.tsv
%       - sub-all_task-Y_desc-roiOverlap.tsv
%       - sub-all_task-Y_desc-meanPSCvalues.tsv
%       - sub-all_task-Y_desc-peakPSCvalues.tsv
%       - sub-all_task-Y_desc-meanCvalues.tsv
%       - sub-all_task-Y_desc-peakCvalues.tsv
%       - sub-all_task-Y_desc-meanTvalues.tsv
%       - sub-all_task-Y_desc-peakTvalues.tsv
% 4.2)  fmrwhy_script_neufepOfflineTCNR
fmrwhy_script_neufepDetermineROImetrics;
fmrwhy_script_neufepOfflineTCNR;

% -------------------------------------------
% STEP 5 - Real-time Processing steps
% -------------------------------------------
fmrwhy_script_neufepRTME; % which runs: 1, 2, 3
fmrwhy_script_rtme_initShort; %1
fmrwhy_script_rtmeShort; %2
fmrwhy_script_rtme_postprocessShort; %3 (saves many tsv files)
fmrwhy_script_neufepRealtimeTCNR; % saves more tsv files
fmrwhy_script_copytcnrFiles; % check if needed (perhaps replace with jupyter notebook content)
rtme_reproduce_methodsFigures; % Generates figures for methods article