% FUNCTION: rtme_preproc_estimateParams
%--------------------------------------------------------------------------

% Copyright statement....

%--------------------------------------------------------------------------
% DEFINITION
%--------------------------------------------------------------------------

%% Calculate tSNR, T2* and S0 from full multi-echo timeseries data
% This is done in order to get an estimate of whole brain tSNR and T2*
% (pre-real-time), which are both used for real-time weighted
% multi-echo-combination (methods i and ii, respectively, from the
% poster).
%
% STEPS:
% 1.
%
% INPUT:
%
% OUTPUT:
%
%--------------------------------------------------------------------------


function output = rtme_preproc_estimateParams(sub, defaults)

% Load required defaults
spm_dir = defaults.spm_dir;
preproc_dir = defaults.preproc_dir;
template_run = defaults.template_run;
template_task = defaults.template_task;
template_echo = defaults.template_echo;
N_e = defaults.N_e;
TE = defaults.TE;
N_vol = defaults.N_vol;
TR = defaults.TR;
N_slices = defaults.N_slices;

% Grab files for preprocessing
% (Functional template is first volume of rest_run-1)
functional0_fn = fullfile(preproc_dir, sub, 'func', [sub '_task-' template_task '_run-' template_run '_echo-' template_echo '_bold.nii,1']);
structural_fn = fullfile(preproc_dir, sub, 'anat', [sub '_T1w.nii']);

% Structure to save outputs
output = struct;

% Create empty arrays
F = cell(N_e,1);
F_ave2D = cell(N_e,1);
F_ave = cell(N_e,1);
F_tSNR2D = cell(N_e,1);
F_tSNR = cell(N_e,1);


% STEP 1 --







% First calculate tSNR per echo timeseries, which is the timeseries
% mean divided by the standard deviation of the timeseries
for e = 1:N_e
    disp(['tSNR for echo ' num2str(e)])
    F{e} = spm_read_vols(spm_vol(rf_me_fn{e}));
    F_ave2D{e} = mean(reshape(F{e},Ni*Nj*Nk, N_vol), 2);
    F_ave{e} = reshape(F_ave2D{e}, Ni, Nj, Nk);
    F_tSNR2D{e} = F_ave2D{e}./std(reshape(F{e},Ni*Nj*Nk, N_vol), 0, 2);
    F_tSNR{e} = reshape(F_tSNR2D{e}, Ni, Nj, Nk);
end

disp('T2star and S0 estimation')
% Then estimate T2* and SO using log linear regression of a simplified
% magnetic signal decay equation (see references in poster) to the data
% derived from averaging the three echo timeseries.
X_pre=[ones(N_e,1) -TE(:)];
S0_pre = zeros(Nvox,1);
T2star_pre = zeros(Nvox,1);
T2star_pre_corrected = T2star_pre;
S_pre = [F_ave2D{1}(I_mask, :)'; F_ave2D{2}(I_mask, :)'; F_ave2D{3}(I_mask, :)'];
S_pre = max(S_pre,1e-11); % negative or zero signal values should not be allowed
b_pre = X_pre\log(S_pre);
S0_pre(I_mask,:)=exp(b_pre(1,:));
T2star_pre(I_mask,:)=1./b_pre(2,:);
% Now threshold the T2star values based on expected (yet broad) range
% of values
T2star_pre_corrected(I_mask) = T2star_pre(I_mask);
T2star_pre_corrected((T2star_pre_corrected(:)<0)) = 0;
T2star_pre_corrected((T2star_pre_corrected(:)>T2star_thresh)) = 0;
% Convert the estimated and corrected parameters to 3D matrices
T2star_pre_img = reshape(T2star_pre_corrected, Ni, Nj, Nk);
S0_pre_img = reshape(S0_pre, Ni, Nj, Nk);

% Save results to nifti images for later use
disp('Save maps')
save('F_tSNR.mat','F_tSNR')
spm_createNII_jsh(template_spm, F_tSNR{1}, [data_dir filesep subj_dir filesep 'tSNR_TE1_pre.nii'], 'tSNR image')
spm_createNII_jsh(template_spm, F_tSNR{2}, [data_dir filesep subj_dir filesep 'tSNR_TE2_pre.nii'], 'tSNR image')
spm_createNII_jsh(template_spm, F_tSNR{3}, [data_dir filesep subj_dir filesep 'tSNR_TE3_pre.nii'], 'tSNR image')
save('T2star_pre_img.mat','T2star_pre_img')
spm_createNII_jsh(template_spm, T2star_pre_img, [data_dir filesep subj_dir filesep 'T2star_pre_img.nii'], 'T2star image')
save('S0_pre_img.mat','S0_pre_img')
spm_createNII_jsh(template_spm, S0_pre_img, [data_dir filesep subj_dir filesep 'S0_pre_img.nii'], 'S0 image')
