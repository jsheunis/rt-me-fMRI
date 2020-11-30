function rtme_util_saveNifti(template_fn, img, new_fn, descrip, pinfo)

new_spm = spm_vol(template_fn);
new_spm.fname = new_fn;
new_spm.private.dat.fname = new_fn;
new_spm.descrip = descrip;
new_spm.private.dat.dim = new_spm(1).private.dat.dim(1:3);
new_spm.n = [1 1];
% Scaling settings: % https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=spm;12fa60a.1205
% Not very sure about this, so hacking it for now:
% pinfo = 1 ==> create new image and ignore scaling of template image; used
% when parameter images e.g. T2* and tSNR are created.
% pinfo = 0 ==> create new image and use existing scaling of template
% image; used when image similar to template image is created (e.g. saving
% one volume from a time series as a singe 3D image)
if pinfo == 1
    new_spm.pinfo(1) = 1; 
end
spm_write_vol(new_spm,img);