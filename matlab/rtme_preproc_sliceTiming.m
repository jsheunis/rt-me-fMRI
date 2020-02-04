function output = rtme_preproc_sliceTiming(functional_fn, prefix, defaults)

% Load required defaults
TR = defaults.TR;
N_slices = defaults.N_slices;
N_vol = defaults.N_vol;
% Create cell array of scan names
scans = {};
for i = 1:N_vol
    scans{i} = [functional_fn ',' num2str(i)];
end

% Create SPM12 batch job
spm('defaults','fmri');
spm_jobman('initcfg');
slice_timing = struct;
slice_timing.matlabbatch{1}.spm.temporal.st.scans = {scans'};
slice_timing.matlabbatch{1}.spm.temporal.st.nslices = N_slices;
slice_timing.matlabbatch{1}.spm.temporal.st.tr = TR;
slice_timing.matlabbatch{1}.spm.temporal.st.ta = TR - TR/N_slices;
slice_timing.matlabbatch{1}.spm.temporal.st.to = 1:N_slices;
slice_timing.matlabbatch{1}.spm.temporal.st.refslice = 1;
slice_timing.matlabbatch{1}.spm.temporal.st.prefix = prefix;
% Run
spm_jobman('run',slice_timing.matlabbatch);
[d, f, e] = fileparts(functional_fn);
output.afunctional_fn = [d filesep prefix f e];