# Study information:

The main purpose of the study is to investigate methods to improve the quality of real-time functional magnetic resonance imaging (fMRI) data.
These improvements are for future applications in real-time fMRI neurofeedback, a method where participants are presented with visual or other feedback of their brain activity while they are inside the MRI scanner, and then asked to regulate the level of feedback.
We have developed real-time multi-echo EPI acquisition sequences and processing methods, and this study aims to collect data from volunteers in order to validate these new methods.


### Summarised study design

While other possible methodological use cases of this data exist, the acquisition plan (i.e. the types, number and order of scans) was mainly designed to mirror that of an fMRI neurofeedback study, without providing feedback.

For rtfMRI-NF studies we require prior information before starting real-time analysis. How do we know where and how to extract the neurofeedback signal? How do we define a template space within which to analyse data in real-time?
To get this prior information, we need to acquire and process extra scans before real-time scanning can commence. This translates to a study design with three steps:

- RUN 1: Pre-real-time data acquisition
- A short period during which to analyse the pre-real-time data
- RUN 2: Real-time data acquisition and analysis using prior information

We are interested in seeing how real-time multi-echo fMRI can be used to improve the quality of the neurofeedback signal (using several metrics).
We want to investigate this on a whole brain level, but we also focus on two regions interesting to the field of rtfMRI-NF: the motor cortex and amygdala.
We have designed tasks to elicit BOLD responses in these areas during RUN 1, such that the derived ROIs can be used to analyse region-specific neurofeedback signals during the mentalized versions of the same tasks in RUN 2 .


### Research questions and outcomes

Three paper approach?

1. Data paper:
    - gives data a DOI, dataset can be cited when used by other researchers
    - fully describing data collection plan and procedure
    - sharing BIDS data and materials
    - gives summary of ethical approval and GDPR aspects
    - running and visualising standard data quality measures
    - other?
2. Is multi-echo better than single echo for real-time use in ROI-driven neurofeedback, using metrics:
    - tSNR (whole brain + ROI voxels + NF signal)
    - tCNR (whole brain + ROI voxels + NF signal)
    - Carpet plots (whole brain + ROI voxels)
    - other?
    
    Additional goal of providing recommendations for real-time processing steps and shared code for community driven rtme-fMRI tool development
3. Exploring the dynamics of combined echoes, T2* and S0 in real-time multi-echo resting state and task fMRI:
    - Can we create a better real-time denoising pipeline using multi-echo parameter estimation and their relation to physiology?
    - With specific interest in physiology signals
    - Possibly looking into partial information decomposition: https://www.biorxiv.org/content/10.1101/596247v3.full
    - other exploratory questions?

#### Paper 1: Data

*tbd*

#### Paper 2: Main focus

There are several ways to define and test for "improvement" of multi-echo vs single echo fMRI for rtfMRI-NF. We plan to investigate the following:

1. Does real-time multi-echo combination help recover signal loss and improve temporal signal to noise ratio in:
    1. Whole brain
    2. Typical dropout areas
    3. Regions of interest for neurofeedback (motor cortex and amygdala)
    
    If so, how much? And how do different combination methods compare?
    
    - *Create carpet plots of all timeseries*
    - *Compare tSNR maps of single echo times eries with variety of combined echo time series*
    - *Compare percentage difference in tSNR maps of single echo times eries with variety of combined echo time series*
    - *Other possible measures:*
        - *DVARS*
        -  *?*

2. Does real-time multi-echo combination and resulting T2* help improve the contrast to noise ratio for task-based neurofeedback? If so, how much? And how do different time series compare?
    
    - *Compare percentage signal change of regulation blocks vs baseline blocks within ROIs (all voxels) for all individual time series*
    - *Create carpet plots of above* 
    - *Compare percentage signal change of regulation blocks vs baseline blocks within ROIs (averaged signal, i.e. NF signal) for all individual time series*
    

#### Paper 3: Later focus

*tbd*

# Data:

Per subject, all of the following data were collected during one scan session (all functional scans are multi-echo EPI):

| Nr | Name  | Scan Type | Description | Format |
| :--- | :--- | :--- | :--- | :--- |
| 1 | T1w | Anatomical | Standard T1-weighted sequence | NIfTI |
| 2 | run1_BOLD_rest | Functional | Resting state | PAR/REC, XML/REC, DICOM |
| 3 | run1_BOLD_task1 | Functional | Motor - finger tapping | PAR/REC, XML/REC, DICOM |
| 4 | run1_BOLD_task2 | Functional | Emotion - shape/face matching | PAR/REC, XML/REC, DICOM |
| 5 | run2_BOLD_rest | Functional | Resting state | PAR/REC, XML/REC, DICOM |
| 6 | run2_BOLD_task1 | Functional | Motor mental - imagined finger tapping | PAR/REC, XML/REC, DICOM |
| 7 | run2_BOLD_task2 | Functional | Emotion mental - recalling emotional memories | PAR/REC, XML/REC, DICOM |
| 8 | Stimulus timing | Peripheral measure | Stimulus and response timing for all tasks, i.e. x4 | Eprime .dat and .txt |
| 9 | Physiology | Peripheral measure | Cardiac + respiratory traces for all runs, i.e. x6 | Philips "scanphyslog" |

fMRI parameters:
 - Philips Achieva 3T
 - Multi-echo EPI sequence, no multi-band
 - TR = 2 s
 - 3 echoes
 - TE = 14, 28, 42 ms (i.e. echo spacing = 14 ms)
 - Voxel size 3.5 mm isotropic
 - In-plane matrix = 64 x 64
 - Slices = 34
 - SENSE factor = 2.5

# Data preparation

See `me_data_setup_workflow.ipynb`

For each dataset (i.e. for each subject) we have to:

1. Move all files into a machine readable directory structure
2. Rename all image files in this directory structure such that BIDS tags are findable
3. Convert data to BIDS:
    1. Run `bidsify` to convert the image data to BIDS (This includes conversion of PAR/REC to NIfTI using `dcm2niix`; this should also include anonymization using `pydeface`, which doesn't work for some reason)
    2. Deface the T1w image using `pydeface`
    3. Run eprime conversion script to convert stimilus and response timings to BIDS (need to figure out this format)
    4. Run `scanphyslog2bids` (or Matlab script if needed) to convert physiology data to BIDS
4. Run the BIDS validator
6. Create summary tables and plots using `pybids`

IMPORTANT:

- [ ] Duplicate full BIDS directory and run processing in duplicate directory, so as not to touch clean BIDS dataset (which is for sharing)

# Data analysis

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
    2. Combined: Linearly-weighted (*and/or summed?*)
    3. Combined: Pre-tSNR-weighted
    4. Combined: Pre-T2*-weighted
    5. Combined: Real-time T2*-weighted
3. Percentage difference maps for tSNR from middle echo to:
    2. Combined: Linearly-weighted (*and/or summed?*)
    3. Combined: Pre-tSNR-weighted
    4. Combined: Pre-T2*-weighted
    5. Combined: Real-time T2*-weighted
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

*Should this be reported as part of the *
- MRIQC
- Own quality checker scripts
- Metrics to use:
	- physiology between conditions
- Real-time quality checking:??
	- FD

# TODO:
- [x] send processing plan to cesar + sveta + lydia + Jaap + Willem
- [ ] Get paper+code of Soroosh Insights into DVARS
- [ ] Pybids for handling BIDS datasets


# IDEAS:
- jupyter notebook with automated pipeline to get 3d printed file from t1 weighted, or something, using: https://github.com/bernhard-42/jupyter-cadquery/



