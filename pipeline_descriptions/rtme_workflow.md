# Data

Per subject, all of the following data were collected during one scan session (all functional scans are multi-echo EPI):

<br>

## Formats

| Nr | Name  | Scan Type | Description | Format |
| :--- | :--- | :--- | :--- | :--- |
| 1 | T1w | Anatomical | Standard T1-weighted sequence | NIfTI |
| 2 | rest_run-1 | Functional | Resting state | PAR/REC, XML/REC, DICOM |
| 3 | fingerTapping | Functional | Motor - finger tapping | PAR/REC, XML/REC, DICOM |
| 4 | emotionProcessing | Functional | Emotion - shape/face matching | PAR/REC, XML/REC, DICOM |
| 5 | rest_run-2 | Functional | Resting state | PAR/REC, XML/REC, DICOM |
| 6 | fingerTappingImagined | Functional | Motor mental - imagined finger tapping | PAR/REC, XML/REC, DICOM |
| 7 | emotionProcessingImagined | Functional | Emotion mental - recalling emotional memories | PAR/REC, XML/REC, DICOM |
| 8 | Stimulus timing | Peripheral measure | Stimulus and response timing for all tasks, i.e. x4 | Eprime .dat and .txt |
| 9 | Physiology | Peripheral measure | Cardiac + respiratory traces for all runs, i.e. x6 | Philips "scanphyslog" |

<br>

## MRI parameters

 - Philips Achieva 3T
 - Multi-echo EPI sequence, no multi-band
 - TR = 2 s
 - 3 echoes
 - TE = 14, 28, 42 ms (i.e. echo spacing = 14 ms)
 - Voxel size 3.5 mm isotropic
 - In-plane matrix = 64 x 64
 - Slices = 34
 - SENSE factor = 2.5

<br>

# Workflow steps

1. [Data preparation](#data_prep)
2. Atlas data preparation
3. Data preprocessing
4. Quality control
5. Multi-echo processing
6. Statistical analysis

<br>

<div id="data_prep"></div>

# 1. Data preparation

Uses `me_data_setup_workflow.ipynb`.

For each dataset (i.e. for each subject) we have to:

1. Move all files into a machine readable directory structure
2. Rename all image files in this directory structure such that BIDS tags are findable
3. Convert data to BIDS:
    1. Run `bidsify` to convert the image data to BIDS (This includes conversion of PAR/REC to NIfTI using `dcm2niix`; this should also include anonymization using `pydeface`, which doesn't work for some reason)
    2. Deface the T1w image using `pydeface`
    3. Run eprime conversion script to convert stimilus and response timings to BIDS
    4. Run `scanphyslog2bids` (or Matlab script if needed) to convert physiology data to BIDS

After the above has finished for all subjects, run [bids validator](https://bids-standard.github.io/bids-validator/).

Possible additions:
- plots / summaries using `pybids`

<br>

# 2. Atlas data preparation

# 3. Data preprocessing

Using `fmrwhy` workflow, `fmrwhy_workflow_qc` and settings file `fmrwhy_settings_RTME` (*SH-TODO: to be completed and saved in this repository*).

Note: *Setting parameter `options.basicfunc_full` set to TRUE in order to run all preproc steps required for further processing, and not only those required for QC.*

Specific steps:
- Create functional template
- Anatomical functional preprocessinf
- Anatomical localiser (from atlas data)
- Functional preprocessing

<br>

# 4. Quality control

# 5. Multi-echo processing

Per subject, processing steps in `fmrwhy_workflow_offlineME`:

- Create functional template (if it doesn't exist already)
- Complete minimal preprocessing for multi-echo combination (if not done already):
    - All tasks and runs.
    - `fmrwhy_preproc_minFunc`
- Calculate tSNR per echo:
    - Template run (`rest_run-1`)
    - Use slice time corrected and realigned functional timeseries.
    - `fmrwhy_util_calculateTSNR`
- Calculate multi-echo decay parameters S0 and T2\*:
    - Template run (`rest_run-1`)
    - Use slice time corrected and realigned functional timeseries.
    - `fmrwhy_util_estimateMEparams`
- Multi-echo combination and time series extraction, for all functional runs except template:
    - 2nd echo
    - Combined tSNR
    - Combined T2\*
    - Combined TE
    - Combined T2\*FIT
    - T2\*FIT
- Calculate tSNR of all six time series (`fmrwhy_util_calculateTSNR`)
- Smooth all of the six time series (`fmrwhy_batch_smooth`)

<br>

Per subject, reporting steps in - `fmrwhy_workflow_offlineMEreport`:

- Visualise T2\* and S0 maps
- For template run (`rest_run-1`):
    - Single BOLD images, all echoes
    - tSNR images, all echoes
- For all other tasks and runs, for all six time series:
    - Single BOLD images, all echoes
    - tSNR images, all echoes
    - `fmrwhy_util_compareTSNRrt`:
        - percentage difference maps
        - raincloudplots
    - ROI timeseries plots (`fmrwhy_util_thePlotROI`)
- Transform all tSNR maps to MNI space (`fmrwhy_batch_normaliseWrite`). WHY? For display in dash? i think so.
- For all tSNR maps in subject space, delineate tSNR values per tissue type and ROI:
    - GM, WM, CSF, brain
    - ROI+ (GM, WM, CSF, brain)
    - Outputs =  TSV files



<br>
<br>







# Data analysis





<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>






Existing / prepared data:
- Atlases from SPM Anatomy Toolbox INM7, saved as separate NIfTIs

## Open questions

- This is strictly speaking an exploratory study and not hypothesis driven. I.e. would not make sense to specify hypothesis and report t and p values. Plan is to calculate improvements i.t.o. percentage difference, and plot distributions using raincloud plots. Sensible?
- Should we test for ME improvements in RS? Or only task? Or both and compare?
- Where to include drift removal?
- How to approach masking for T2* and S0 estimation?
- How to define task ROIs
- Signal scaling: this is not explicitly applied anywhere except implicitly by SPM in the GLM analysis when creating functional localisers.
Should we apply signal scaling (grand mean / something else?) at other points in the pipeline? Are we missing something? 
- Where to submit?
- Data paper?
  
## Subject-level

- Preproc for getting prior estimates of T2* and S0
- Preproc for getting functional

### Pre-processing: anatomical (RUN 1)

1. Anatomical to functional space coregistration, use middle echo first volume as template - SPM12 coregister estimate
2. Segment coregistered anatomical image into tissue components - SPM12 unified segmentation
    1. Saves inverse transform from subject functional to MNI space
3. Coregister relevant regions of interest (from atlases in MNI space) to subject functional space using inverse transfromations
4. Reslice all to functional space grid (SPM reslice)


### Pre-processing: peripheral data (RUN 1)

1. Generate RETROICOR regressors from cardiac and respiratory traces of both runs (run 2 data to be used later) - PhysIO + Matlab


### Pre-processing: functional (RUN 1)

1. Task region localisation (using only middle echo [TE=28ms] timeseries):
    1. Slice time correction
    2. 3D volume realignment
    3. Calculate framewise displacement from realignment params, select outliers using FD threshold (*which value or percentage?*)
    4. Gaussian kernel smoothing (2*voxel size?)
    5. GLM analysis incl:
        1. AR(1) autoregressive filtering
        2. Drift removal / high-pass (SPM cosine basis set)
        3. Realignment params [+expansion?]
        4. RETROICOR (+HRV, RTV?)
        5. FD outlier binary regressor
        6. *(global or tissue compartment signals???)*
    6. Select t-stat peak within anatomically bound mask (from anatomy toolbox ROI)
    7. Select N amount of voxels neighbouring peak voxel ==> ROI for real-time use

2. T2*, S0, tSNR calculation from `run1_BOLD_rest` dataset (*is this sensible, as opposed to using RUN 1 task data?*):
    1. Slice time correction on all three echo timeseries
    2. 3D volume realignment on middle echo timeseries
    3. Apply rigid body transformations from middle echo realignment parameters to echo 1 and echo 3 timeseries
    6. T2* and S0 estimation (*check steps of tedana*):
        1. *How to mask?*
        2. Calculate timeseries average
        3. Estimate T2* and S0 using log-linear fit of mono-exponential decay model
        4. *Threshold?*
    4. *Drift removal?*
    5. tSNR calculation:
        1. *How to mask?*
        2. Mean / stddev
    

### Real-time processing (RUN 2)

Do the following per time-point:

1. Slice time correction on all three echoes
2. 3D volume realignment on middle echo
3. Apply rigid body transformations from middle echo realignment parameters to echo 1 and echo 3
4. *Drift removal?*
5. Real-time T2* and S0 estimation:
    1. *How to mask?*
    3. Estimate T2* and S0 from current timepoint echoes using log-linear fit of mono-exponential decay model
    4. *Threshold?*
6. Multi-echo combination:
    1. Linearly-weighted (*and/or summed?*)
    2. Pre-tSNR-weighted
    3. Pre-T2*-weighted
    4. Real-time T2*-weighted
7. Gaussian kernel smoothing (2 x voxel size?) of echo combinations, of T2* and of middle echo.
8. Calculate neurofeedback signal using OpenNFT methodology:
	1. Mask using 
	2. Average within mask
	3. Incremental GLM a la OpenNFT, includes:
	    1. Low-pass filter / *drift removal?*
	    2. AR(1) filter
	    3. Motion parameters
	    4. *what else?*
	4. *(include Kalman filter? don't think we should)*
	5. NFB trace (before and after OpenNFT scaling)

### Post real-time analysis:

*Is this where signal scaling / normalisation needs to come in?*

1. tSNR maps for following timeseries:
    1. Middle echo
    2. Combined: Linearly-weighted (*and/or summed?*)
    3. Combined: Pre-tSNR-weighted
    4. Combined: Pre-T2*-weighted
    5. Combined: Real-time T2*-weighted
    6. T2*
2. Percentage difference maps for tSNR from middle echo to:
    1. Combined: Linearly-weighted (*and/or summed?*)
    2. Combined: Pre-tSNR-weighted
    3. Combined: Pre-T2*-weighted
    4. Combined: Real-time T2*-weighted
3. Percentage difference maps for tSNR from middle echo to:
    1. Combined: Linearly-weighted (*and/or summed?*)
    2. Combined: Pre-tSNR-weighted
    3. Combined: Pre-T2*-weighted
    4. Combined: Real-time T2*-weighted
3. Extract measures for ROIs


## Group level

WHAT TO COMPARE:
- Single (middle) echo vs. echo combination (various methods) vs R2star
- Metrics and visualisation:
	- tSNR (rs brain + task brain + task ROIs)
	- tCNR (BOLD percentage signal change; rs brain + task brain + task ROIs)
	- PSC brain maps and raincloudlots of above
	- DVARS (rs brain + task brain + task ROIs)
	- ThePlot whole brain + task ROI
	- physiology between conditions


# Quality control

*Idea is for this to be reported as part of the Data Paper*

- MRIQC from BIDS (derivatives)
- Own quality checker scripts
- Extra metrics to report:
	- physiology between conditions
- Real-time quality control metrics (from rtQC):
	- FD
	- other?

# TODO:
- [x] send processing plan to cesar + sveta + lydia + Jaap
- [ ] Get paper+code of Soroosh Insights into DVARS
- [ ] Pybids for handling BIDS datasets


# IDEAS:
- jupyter notebook with automated pipeline to get 3d printed file from t1 weighted, or something, using: https://github.com/bernhard-42/jupyter-cadquery/



