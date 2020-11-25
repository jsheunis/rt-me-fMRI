data_dir = '/Users/jheunis/Desktop/sample-data/sub-neufepmetest/';
sub = 'sub-pilot';
sub_dir = [data_dir filesep sub];
func_dir = [sub_dir filesep 'func'];
anat_dir = [sub_dir filesep 'anat'];

scanphyslog_fn = [func_dir filesep 'SCANPHYSLOG_sub-pilot_emotion2.log'];

TR = 2000;
Ndyn = 210;
[x, ppu, resp, outParams, waveforms] = getPPUandResp(scanphyslog_fn, TR, Ndyn);

figure;

plot(x, resp, 'r')

