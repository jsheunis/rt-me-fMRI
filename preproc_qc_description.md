
# Subject-level

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



