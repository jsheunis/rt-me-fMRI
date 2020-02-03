function rtme_util_saveNifti(template_fn, img, new_fn, descrip)

new_spm = spm_vol(template_fn);
new_spm.fname = new_fn;
new_spm.private.dat.fname = new_fn;
new_spm.descrip = descrip;
new_spm.private.dat.dim = new_spm(1).private.dat.dim(1:3);
new_spm.n = [1 1];
new_spm.pinfo(1) = 1; % https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=spm;12fa60a.1205
spm_write_vol(new_spm,img);