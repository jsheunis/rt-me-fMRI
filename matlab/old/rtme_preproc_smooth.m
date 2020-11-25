function output = rtme_preproc_smooth(functional_fn, prefix, defaults)

% Load required defaults
TR = defaults.TR;
fwhm = defaults.smoothing_kernel;
N_vol = defaults.N_vol;
% Create cell array of scan names
scans = {};
for i = 1:N_vol
    scans{i} = [functional_fn ',' num2str(i)];
end

% Create SPM12 batch job
spm('defaults','fmri');
spm_jobman('initcfg');
smooth = struct;
smooth.matlabbatch{1}.spm.spatial.smooth.data = scans';
smooth.matlabbatch{1}.spm.spatial.smooth.fwhm = fwhm;
smooth.matlabbatch{1}.spm.spatial.smooth.dtype = 0;
smooth.matlabbatch{1}.spm.spatial.smooth.im = 0;
smooth.matlabbatch{1}.spm.spatial.smooth.prefix = prefix;
% Run
spm_jobman('run',smooth.matlabbatch);
[d, f, e] = fileparts(functional_fn);
output.sfunctional_fn = [d filesep prefix f e];