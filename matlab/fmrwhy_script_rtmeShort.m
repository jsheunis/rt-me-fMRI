
%--------------------------------------------------------------------------
% DEFINITION
%--------------------------------------------------------------------------
%
%
%
% TODO: NOTE - EVERYTHING IS READ IN AND SAVED WITH SPM_VOL (ETC) AND NOT USING NII_TOOL
%--------------------------------------------------------------------------
% DATA INITIALIZATION FOR ONLINE USE
%--------------------------------------------------------------------------

% Here we mostly create empty variables to be used/populated in real-time
% We also set up all the axes for real-time display
N_roi = N_ROIs;
F = cell(numel(echoes),1);
F_dyn_denoised = F;
rF = F;
srF = nan(Nx*Ny*Nz,Ndyn);
realign_params = F;
fdyn_fn = F;
F_dyn_img = F;
currentVol = F;

I_activeVoxels = cell(1,Ndyn);
NEG_e2n = cell(1,Ndyn);
base3D = cell(Ne,1);

% fMRI data might be multi-echo (i.e. multiple images per volume, not the
% case in the sample data). Create variables per echo.
R = cell(Ne,1);
reslVol = cell(Ne,1);
for e = 1:Ne
    F{e} = nan(Nx*Ny*Nz,Ndyn);
    F_dyn_denoised{e} = nan(Nx*Ny*Nz,Ndyn);
    rF{e}  = nan(Nx*Ny*Nz,Ndyn);
    R{e}(1,1).mat = funcref_spm.mat;
    R{e}(1,1).dim = funcref_spm.dim;
    R{e}(1,1).Vol = funcref_3D;
end
% More Multi-echo variables
if Ne > 1
    e_ref = str2double(options.template_echo);
    X = [ones(Ne,1) -TE(:)];
    base = zeros(Nvox,Ndyn);
    S0 = base;
    T2star = base;
    T2star_corrected = T2star;
    T2star_img = zeros(Nx, Ny, Nz, Ndyn);
    T2star_pv_img = zeros(Nx, Ny, Nz, Ndyn);
    S0_img = zeros(Nx, Ny, Nz, Ndyn);
    S0_pv_img = zeros(Nx, Ny, Nz, Ndyn);
    S_combined_img = zeros(Nx, Ny, Nz, Ndyn);
    S_combined_img2 = zeros(Nx, Ny, Nz, Ndyn);
    S0_pv = base;
    T2star_pv = base;
    T2star_pv_corrected = T2star_pv;
    S0_pv_corrected = S0_pv;
    combined_te_pre = base;
    combined_t2s_pre = base;
    combined_tsnr_pre = base;
    combined_t2s_rt = base;
end

% sub-001_task-fingerTapping_desc-s0FIT_bold.nii

% movement parameters
mp_fn = fullfile(options.preproc_dir, ['sub-' sub], 'func', ['sub-' sub '_task-', task, '_echo-2_desc-confounds_motion.tsv']);
mp_full = struct2array(tdfread(mp_fn));


%%
%--------------------------------------------------------------------------
% REAL-TIME ANALYSIS
%--------------------------------------------------------------------------

% Loop through all real-time volumes and conduct iterative analysis
for i = 1:Nt

    tic;
    % Display iteration number
    disp(['i = ' num2str(i)])
    % Skip iteration based on specified amount of initial volumes to skip
    if i <= N_skip
        continue;
    end
    j = i - N_skip;
    
    % get current MPs
    if (i == N_start)
        offsetMCParam = mp_full(j, 1:6);
    end
    MP(j,:) = mp_full(j, 1:6) - offsetMCParam;

%     % Reslice (FROM OPENNFT: preprVol.m) - method 1:
%     reslVol{e_ref} = fmrwhy_realtime_reslice(R{e_ref}, flagsSpmReslice, currentVol{e_ref});
%     rF{e_ref}(:,j) = reslVol{e_ref}(:);
%     for e = 1:Ne
%         if e == e_ref
%             continue;
%         end
% %        F{e}(:,:,:,j) = F_dyn_img{e};
%         Pm = zeros(12,1);
%         Pm(1:6) = MP(j, :);
%         orig_mat = currentVol{e}.mat;
%         rigid_mat = spm_matrix(Pm, 'T*R');
%         trans_mat = rigid_mat * orig_mat;
%         R{e}(2,1).dim = currentVol{e}.dim;
%         R{e}(2,1).Vol = F_dyn_img{e};
%         R{e}(2,1).mat = trans_mat;
%         reslVol{e} = fmrwhy_realtime_reslice(R{e}, flagsSpmReslice, currentVol{e});
%         rF{e}(:,j) = reslVol{e}(:);
%     end
%     toc;

%
%    % STEP 2 + 3: REALIGN AND RESLICE TO REFERENCE VOLUME
%    % First realign template echo to template volume
%    % Method 2
%    R(2,1).mat = currentVol{e}.mat;
%    R(2,1).dim = currentVol{e}.dim;
%    R(2,1).Vol = F_dyn_img{e};
%    % realign (FROM OPENNFT: preprVol.m)
%    [R, A0, x1, x2, x3, wt, deg, b, nrIter] = spm_realign_rt(R, flagsSpmRealign, i, N_start, A0, x1, x2, x3, wt, deg, b);
%    % MC params (FROM OPENNFT: preprVol.m)
%    tmpMCParam = spm_imatrix(R(2,1).mat / R(1,1).mat);
%    if (i == N_start)
%        offsetMCParam = tmpMCParam(1:6);
%    end
%    motCorrParam(j,:) = tmpMCParam(1:6)-offsetMCParam; % STEPHAN NOTE: I changed indVolNorm to indVol due to error, not sure if this okay or wrong?
%    MP(j,:) = motCorrParam(j,:);
%    % Reslice (FROM OPENNFT: preprVol.m)
%    reslVol = spm_reslice_rt(R, flagsSpmReslice);
%    rF{e}(:,j) = reslVol(:);
%
%    for e = 1:Ne
%        if e == str2double(options.template_echo)
%            continue;
%        end
%
%
%    end


    % % STEP 4: MULTI-ECHO PARAMETER ESTIMATION AND COMBINATION (not for sample data)
    % if Ne > 1
    %     % If option selected to use all echoes (i.e. use_echo = 0) continue
    %     % with multi-echo parameter estimation and combination, else use
    %     % specified echo (e.g use_echo = 2)
    %     if use_echo == 0

    %         me_params = fmrwhy_realtime_estimateMEparams(reslVol, options.TE, I_mask);
    %         T2star_pv(:,j) = reshape(me_params.T2star_3D, Nx*Ny*Nz, 1);
    %         S0_pv(:,j) = reshape(me_params.S0_3D, Nx*Ny*Nz, 1);
    %         T2star_pv_corrected(:,j) = reshape(me_params.T2star_3D_thresholded, Nx*Ny*Nz, 1);
    %         S0_pv_corrected(:,j) = reshape(me_params.S0_3D_thresholded, Nx*Ny*Nz, 1);

    %         func_data = zeros(Nx, Ny, Nz, Ne);
    %         for e = 1:Ne
    %             func_data(:,:,:,e) = reslVol{e};
    %         end
    %         combined_t2s_pre_3D = fmrwhy_me_combineEchoes(func_data, options.TE, 0, 1, t2star_img);
    %         combined_t2s_rt_3D = fmrwhy_me_combineEchoes(func_data, options.TE, 0, 1, me_params.T2star_3D);
    %         combined_tsnr_pre_3D = fmrwhy_me_combineEchoes(func_data, options.TE, 0, 2, tsnr_data);
    %         combined_te_pre_3D = fmrwhy_me_combineEchoes(func_data, options.TE, 0, 3, options.TE);
    %         combined_t2s_pre(:,j) = combined_t2s_pre_3D(:);
    %         combined_t2s_rt(:,j) = combined_t2s_rt_3D(:);
    %         combined_tsnr_pre(:,j) = combined_tsnr_pre_3D(:);
    %         combined_te_pre(:,j) = combined_te_pre_3D(:);

    %         signals_raw_3D{1}(:,:,:,j) = reslVol{2};                       % Echo 2
    %         signals_raw_3D{2}(:,:,:,j) = combined_tsnr_pre_3D;             % Pre-tSNR combined
    %         signals_raw_3D{3}(:,:,:,j) = combined_t2s_pre_3D;              % Pre-T2* combined
    %         signals_raw_3D{4}(:,:,:,j) = combined_te_pre_3D;               % Pre-TE combined
    %         signals_raw_3D{5}(:,:,:,j) = combined_t2s_rt_3D;               % RT-T2* combined
    %         signals_raw_3D{6}(:,:,:,j) = me_params.T2star_3D_thresholded;  % T2* FIT
    %         signals_raw_3D{7}(:,:,:,j) = me_params.S0_3D_thresholded;      % S0 FIT

    %         signals_raw{1}(:,j) = reslVol{2}(:);
    %         signals_raw{2}(:,j) = combined_tsnr_pre(:,j);
    %         signals_raw{3}(:,j) = combined_t2s_pre(:,j);
    %         signals_raw{4}(:,j) = combined_te_pre(:,j);
    %         signals_raw{5}(:,j) = combined_t2s_rt(:,j);
    %         signals_raw{6}(:,j) = T2star_pv_corrected(:,j);
    %         signals_raw{7}(:,j) = S0_pv_corrected(:,j);

    %         rf = combined_tsnr_pre_3D;
    %     else
    %         rf = rF{use_echo}(:,j);
    %     end
    % else
    %     % if single-echo, use first volume in rF cell array
    %     rf = rF{1}(:,j);
    % end

    % STEP 5: SMOOTH REALIGNED VOLUME
    % Using OpenNFT functionality and SPM
    for sig = 1:numel(signals_raw_3D)
        srf = zeros(Nx, Ny, Nz);
        gKernel = smoothing_kernel ./ dicomInfoVox;
        spm_smooth(squeeze(signals_raw_3D{sig}(:,:,:,j)), srf, gKernel);
        signals_smoothed_3D{sig}(:,:,:,j) = srf;
        signals_smoothed{sig}(:,j) = srf(:);
        % srF(:,j) = srf(:);
    end

%    % STEP 6: AR(1) FILTERING OF SMOOTHED VOLUME (for neufep: false)
%    if iglmAR1
%        if j == 1
%            % initalize first AR(1) volume
%            asrF(:,j) = (1 - aAR1) * srF(:,j);
%        else
%            asrF(:,j) = srF(:,j) - aAR1 * asrF(:,j-1);
%        end
%    else
%        asrF(:,j) = srF(:,j);
%    end
%
%    % STEP 7: iGLM FOR VOLUME (for neufep: false)
%    if isIGLM
%        % Scaling settings
%        if fLockedTempl
%            if j == 1
%                % Only set the scaling settings based on first iteration
%                max_smReslVol = max(asrF(:,j));
%                min_smReslVol = min(asrF(:,j));
%                normSmReslVol = (asrF(:,j)-min_smReslVol) / (max_smReslVol-min_smReslVol);
%            end
%        else
%            % Update scaling settings on each iteration
%            max_smReslVol = max(asrF(:,j));
%            min_smReslVol = min(asrF(:,j));
%            normSmReslVol = (asrF(:,j)-min_smReslVol) / (max_smReslVol-min_smReslVol);
%        end
%
%        % Constant regressor is always included
%        constRegr = constRegrFull(1:j);
%        if isRegrIGLM
%            % Create empty nuisance regressors
%            motRegr = [];
%            linRegr = [];
%            highPassRegr = [];
%            % Set regressor content if they need to be included in design
%            % matrix
%            if isMotionRegr
%                if Ne > 1
%                    motRegr = zscore(MP(1:j,:));
%                else
%                    motRegr = zscore(MP(1:j,:));
%                end
%            end
%            if isLinRegr
%                linRegr = linRegrFull(1:j);
%            end
%            if isHighPass
%                highPassRegr = cosine_basis_set(1:j, :);
%            end
%            % Construct design matrix without task/baseline conditions, i.e.
%            % including nuisance and constant regressors
%            tmpRegr = horzcat(motRegr, linRegr, highPassRegr, constRegr);
%        else
%            tmpRegr = constRegr;
%        end
%        nrBasFctRegr = size(tmpRegr, 2);
%
%        % AR(1) for regressors of no interest
%        if iglmAR1
%            tmpRegr = arRegr_opennft(aAR1,tmpRegr);
%        end
%        % combine with prepared basFct design regressors
%        basFctRegr = [basFct(1:j,:), tmpRegr];
%
%        % estimate iGLM
%        [idxActVoxIGLM, dyntTh, tTh, Cn, Dn, s2n, tn, neg_e2n] = ...
%            onlineBrain_iGLM(Cn, Dn, s2n, tn, asrF(:,j), j, ...
%            (nrBasFct+nrBasFctRegr), tContr, basFctRegr, pVal, ...
%            dyntTh, tTh, spmMaskTh);
%
%        % catch negative iGLM estimation error message for log
%        NEG_e2n{j} = neg_e2n;
%        if ~isempty(neg_e2n)
%            disp('HERE THE NEGATIVE e2n!!!')
%        end
%        I_activeVoxels{j} = idxActVoxIGLM;
%    else
%        idxActVoxIGLM = [];
%    end
%    % handle empty activation map and division by 0
%    if ~isempty(idxActVoxIGLM) && max(tn) > 0
%        maskedStatMapVect = tn(idxActVoxIGLM);
%        maxTval = max(maskedStatMapVect);
%        statMapVect = maskedStatMapVect;
%        statMap3D(idxActVoxIGLM) = statMapVect;
%        statMap4D{j} = statMap3D;
%    end

    % STEP 8 + 9 + 10: cGLM NUISANCE REGRESSION, KALMAN FILTERING AND SCALING OF SIGNAL IN ROI(s)
%    if isPhysRegr
%        rawTimeSeriesREF(N_ROI_REF,j) = nanmean(asrF(I_roi{N_ROI_REF},j));
%    end

    for roi = 1:numel(ROI_img)

        for sig = 1:numel(signals_raw_3D)
            rawTimeSeries{sig}(roi,j) = nanmean(signals_smoothed{sig}(I_roi{roi},j));

            % Limits for scaling
            initLim{sig}(roi) = 0.005*nanmean(rawTimeSeries{sig}(roi,1:j));

            % Raw for Display (STEPHAN: FIGURE OUT WHY THIS IS DONE)
            displRawTimeSeries{sig}(roi,j) = rawTimeSeries{sig}(roi, j)-rawTimeSeries{sig}(roi, 1);

            % To avoid NaNs given algnment to zero, see preprVol()
            motCorrParam(1,:) = 0.00001;

            % Get full time series up to current iteration
            tmp_rawTimeSeries = rawTimeSeries{sig}(roi, 1:j)';
            % tmp_rawTimeSeriesREF = rawTimeSeriesREF(roi, 1:j)';

            % Time-series AR(1) filtering
            if cglmAR1
                % initalize first AR(1) value
                if j == 1
                    tmp_rawTimeSeriesAR1(roi,j) = (1 - aAR1) * tmp_rawTimeSeries(j);
                else
                    tmp_rawTimeSeriesAR1(roi,j) = tmp_rawTimeSeries(j) - aAR1 * tmp_rawTimeSeriesAR1(roi,j-1);
                end
                % replace raw ime-series with AR(1) time-series
                clear tmp_rawTimeSeries
                tmp_rawTimeSeries = tmp_rawTimeSeriesAR1(roi, :)';
            end

            % Setup design matrix regressors
            constRegrC = constRegrFull(1:j); % Constant regressor is always included
            linRegrC = [];
            motRegrC = [];
            designRegrC = [];
            physRegrC = [];

            % Step-wise addition of regressors, step = total nr of regressors,
            % which may require a justification for particular project
            regrStep = nrRegrToCorrect + nrRegrDesign; % 1 + 1 + 6 + 1 = 9;
            if j < regrStep
                % only include constant regressor
            elseif (j >= regrStep) && (j < 2*regrStep)
                % include constant and linear regressors
                linRegrC = linRegrFull(1:j);
            else %(j >= 2*regrStep)
                % include constant, linear and motion correction regressors
                linRegrC = linRegrFull(1:j);
                if Ne > 1
                    motRegrC = zscore(MP(1:j,:));
                else
                    motRegrC = zscore(MP(1:j,:));
                end
                if isPhysRegr
                    physRegrC = rawTimeSeriesREF(N_ROI_REF,1:j)';
                end
            end

            % Concatenate regressors of no interest
            % tmpRegr = horzcat(linRegrC, motRegrC);
            tmpRegr = horzcat(constRegrC, linRegrC, motRegrC);
            if isPhysRegr
                % tmpRegr = horzcat(linRegrC, motRegrC, physRegrC);
                tmpRegr = horzcat(constRegrC, linRegrC, motRegrC, physRegrC);
            end

            % AR(1) for regressors of no interest
            if cglmAR1
                tmpRegr = arRegr_opennft(aAR1,tmpRegr); %TODO, rename and move this function?
            end

            % Create final design matrix and estimate GLM parameters
            if j < 3*regrStep
                % estimate GLM parameters for case where task regressor is not
                % included
                cX = tmpRegr;
                beta = pinv(cX) * tmp_rawTimeSeries;
                tmp_glmProcTimeSeries = (tmp_rawTimeSeries - cX * beta)';
            else
                % First include task regressor into design matrix
                cX = [tmpRegr spmDesign(1:j,:)];
                beta = pinv(cX) * tmp_rawTimeSeries;
                tmp_glmProcTimeSeries = (tmp_rawTimeSeries - cX * [beta(1:end-1); zeros(1,1)])';
            end

            glmProcTimeSeries{sig}(roi, j) = tmp_glmProcTimeSeries(end);

            % Modified Kalman low-pass filter + spike identification & correction
            tmpStd = std(glmProcTimeSeries{sig}(roi,1:j));
            S(roi).Q = tmpStd^2;
            S(roi).R = 1.95*tmpStd^2;
            kalmThreshold = 0.9*tmpStd;


            % IMPORTANT THIS PART WAS ONLY PUT HERE TO DEAL WITH ISSUES FROM A PROBLEM SUBJECT: 11 OR 12?????? CHECK OUTPUT DATES TO SEE WHICH ONE, BECAUSE IT WAS RUN LAST
            if (roi==6)
                kalmanProcTimeSeries{sig}(roi,j) = glmProcTimeSeries{sig}(roi, j);
            else
                [kalmanProcTimeSeries{sig}(roi,j), S(roi), fPositDerivSpike(roi), fNegatDerivSpike(roi)] = ...
                onlineBrain_modifKalman(kalmThreshold, glmProcTimeSeries{sig}(roi,j), S(roi), fPositDerivSpike(roi), fNegatDerivSpike(roi));
            end

            % Scaling: TODO: decide if need to SKIP KALMAN FILTERING ==> PUT GLMPROCTIMESERIES INTO SCALING FUNCTION BELOW
            slWind = basBlockLength * nrBlocksInSlidingWindow;
            [scalProcTimeSeries{sig}(roi, j), tmp_posMin{sig}(roi), tmp_posMax{sig}(roi)] = ...
                onlineBrain_scaleTimeSeries(kalmanProcTimeSeries{sig}(roi,1:j), j, slWind, basBlockLength, initLim{sig}(roi), vectEncCond(1:j), tmp_posMin{sig}(roi), tmp_posMax{sig}(roi));
            posMin{sig}(roi,j)=tmp_posMin{sig}(roi);
            posMax{sig}(roi,j)=tmp_posMax{sig}(roi);

        end
    end

    for sig = 1:numel(signals_raw_3D)
        % calcualte average limits for 2 ROIs, e.g. for bilateral NF
        % NF extensions with >2 ROIs requires an additional justification
        mposMax{sig}(j)= nanmean(posMax{sig}(:, j));
        mposMin{sig}(j)= nanmean(posMin{sig}(:, j));

        % STEP 11: NEUROFEEDBACK SIGNAL CALCULATION / PRESENTATION
        if baseline_design(j) == 1
            % If the current iteration is in a baseline block, feedback value
            % is zero for all ROIs
            NFB{sig}(:,j) = 0;
            NFB_disp{sig}(:,j) = 0;
        else
            % If the current iteration is in a task block, feedback value
            % is calculated as PSC of current value compared to cumulative
            % basline nanmean/median. This is done per ROI
            i_bas = I_baseline(I_baseline<j);
            for roi = 1:numel(ROI_img)
                mBas = median(scalProcTimeSeries{sig}(roi,i_bas));
                mCond = scalProcTimeSeries{sig}(roi,j);
                norm_percValues{sig}(roi, j) = mCond - mBas;
                % tmp_fbVal = median(norm_percValues); ==> OpenNFT calculates
                % median over ROIs, e.g. when interested in signal in multiple
                % ROIs like bilateral occipital cortices
                NFB{sig}(roi,j) = norm_percValues{sig}(roi, j);
                NFB_disp{sig}(roi,j) = round(10000 * NFB{sig}(roi,j)) /100;
                % [1...100], for Display
                if NFB_disp{sig}(roi,j) < 1
                    NFB_disp{sig}(roi,j) = 1;
                end
                if NFB_disp{sig}(roi,j) > 100
                    NFB_disp{sig}(roi,j) = 100;
                end
            end
        end
    end

    % STEP 12: UPDATE PLOTS
    % TODO: ROIPOLY to draw a polygon for user-specified roi (e.g. extract signal)
    % TODO: INPOLYGON to check if buttonpress is inside mask/ROI boundary
%    if showMontage
%    else
%        if ~isempty(idxActVoxIGLM)
%            tmap = statMap4D{j};
%            tmap_masked = zeros(size(tmap));
%            tmap_masked(I_mask) = tmap(I_mask);
%            tmap_rot = rot90(squeeze(tmap_masked(:,:,Nslice)),rotateVal);
%            normA = tmap_rot - min(tmap_rot(:));
%            normA = normA ./ max(normA(:));
%            set(im2, 'AlphaData', normA);
%        end
%    end
%    set(ln1, 'XData', [j j]);
%    plt_sig = 2;
%    set(pl2, 'YData', rawTimeSeries{plt_sig}(roi1,:));
%    set(pl22, 'YData', rawTimeSeries{plt_sig}(roi2,:));
%    set(pl3, 'YData', kalmanProcTimeSeries{plt_sig}(roi1,:)); % TODO: change between displaying kalman filtered time series and glm processed time series
%    set(pl32, 'YData', kalmanProcTimeSeries{plt_sig}(roi2,:));
%    set(b_handle, 'Ydata', NFB_disp{plt_sig}(roi2,j))
%    drawnow;
toc;
end
