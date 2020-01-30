 %% Load






%% Pre-real-time preproc
% Now, this step is executed once all settings are completed. We first
% check if the data has been preprocessed already. If so, we just load and
% name the variables. If not we run the standard preprocesing pipeline.
[d, fn, ext] = fileparts(structural_fn);
% We check if the data has been preprocessed by searching for the filename
% of one of the files that are generated during preprocessing (here, the
% resliced grey matter segmentation image)
if exist([d filesep 'rc1' fn ext], 'file')
    % Just load file/variable names, don't redo preprocessing
    disp('Preprocessing already done - loading variables')
    preproc_data = struct;
    [d, fn, ext] = fileparts(structural_fn);
    preproc_data.forward_transformation = [d filesep 'y_' fn ext];
    preproc_data.inverse_transformation = [d filesep 'iy_' fn ext];
    preproc_data.gm_fn = [d filesep 'c1' fn ext];
    preproc_data.wm_fn = [d filesep 'c2' fn ext];
    preproc_data.csf_fn = [d filesep 'c3' fn ext];
    preproc_data.bone_fn = [d filesep 'c4' fn ext];
    preproc_data.soft_fn = [d filesep 'c5' fn ext];
    preproc_data.air_fn = [d filesep 'c6' fn ext];
    preproc_data.rstructural_fn = [d filesep 'r' fn ext];
    preproc_data.rgm_fn = [d filesep 'rc1' fn ext];
    preproc_data.rwm_fn = [d filesep 'rc2' fn ext];
    preproc_data.rcsf_fn = [d filesep 'rc3' fn ext];
    preproc_data.rbone_fn = [d filesep 'rc4' fn ext];
    preproc_data.rsoft_fn = [d filesep 'rc5' fn ext];
    preproc_data.rair_fn = [d filesep 'rc6' fn ext];

    % Check if ROIs are specified to be in native space and run warping or
    % not based on setting
    if ROI_native
        % ROIs are already in native space, no warping necessary
        preproc_data.ROI_fns = ROI_fns;
    else
        % This part was hardcoded for testing purposes, it doesnt actually
        % call the warping functionality here, which it should do. TODO
        for roi = 1:(N_ROIs-N_RNOIs)
            [droi, fnroi, extroi] = fileparts(ROI_fns{roi});
            preproc_data.wROI_fns{roi} = [droi filesep 'w' fnroi extroi];
            preproc_data.rwROI_fns{roi} = [droi filesep 'rw' fnroi extroi];
        end
        preproc_data.ROI_fns = preproc_data.rwROI_fns;
    end
else
    % If preproc not done, call preprocessing script
    preproc_data = onlineBrain_preRtPreProc(functional0_fn, structural_fn, spm_dir);

    % Also do ROI warping to get everything in same space
    if ROI_native
        % ROIs are already in native space, no warping necessary
        preproc_data.ROI_fns = ROI_fns;
    else
        % ROIs are in MNI space, warping and reslicing necessary
        % Warp MNI space rois to functional space,...
        spm_normalizeWrite_jsh(preproc_data.inverse_transformation, ROI_fns(1:(end-N_RNOIs)));
        for roi = 1:(N_ROIs-N_RNOIs)
            [droi, fnroi, extroi] = fileparts(ROI_fns{roi});
            preproc_data.wROI_fns{roi} = [droi filesep 'w' fnroi extroi];
        end
        % ... then reslice
        spm('defaults','fmri');
        spm_jobman('initcfg');
        reslice = struct;
        % Ref
        reslice.matlabbatch{1}.spm.spatial.coreg.write.ref = {functional0_fn};
        % Source
        source_fns = preproc_data.wROI_fns;
        reslice.matlabbatch{1}.spm.spatial.coreg.write.source = source_fns';
        % Roptions
        reslice.matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 4;
        reslice.matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
        reslice.matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
        reslice.matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';
        % Run
        spm_jobman('run',reslice.matlabbatch);
        for roi = 1:(N_ROIs-N_RNOIs)
            [droi, fnroi, extroi] = fileparts(ROI_fns{roi});
            preproc_data.rwROI_fns{roi} = [droi filesep 'rw' fnroi extroi];
        end
        preproc_data.ROI_fns = preproc_data.rwROI_fns;
    end

end