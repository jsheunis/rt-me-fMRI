#!/usr/bin/bash

# You need to have AFNI installed for this script to work.

set pdir = `pwd`

filename=participants_wo_heading_1.tsv
declare -a participantsArray
participantsArray=(`cat "$filename"`)

for i in "${participantsArray[@]}"
do
	# mkdir "/home/tue/jheunis/fs_derivatives/$i"
	# cp -p "/home/tue/jheunis/freesurfer/subjects/$i/mri/aparc+aseg.mgz" "/home/tue/jheunis/fs_derivatives/$i/"
	# cd "/home/tue/jheunis/fs_derivatives/$i/"
	# mri_convert aparc+aseg.mgz aparc+aseg.nii

	cd "$i"
	
	set masterimg = ${pdir}/data/sub-002_space-individual_desc-coregEstResl_T1w.nii

	# rm -rf ${pdir}/data/*_ero*.nii

	echo ----------------------------------------------------------
	echo ----------------------------------------------------------
	echo CREATE MASKS FROM FREESURFER SEGMENTATION
	echo ----------------------------------------------------------
	echo ----------------------------------------------------------

	# extract the GM, WM, CSF, and WB compartments

	# Grey matter:
	#   Subcortical nuclei:
	#   - 10: Left-Thalamus-Proper
	#   - 11: Left-Caudate
	#   - 12: Left-Putamen
	#   - 49: Right-Thalamus-Proper
	#   - 50: Right-Caudate
	#   - 51: Right-Putamen
	#   Cerebellum:
	#   - 8: Left-Cerebellum-Cortex
	#   - 47: Right-Cerebellum-Cortex
	#   Hippocampus and amygdala
    #   - 17: Left-Hippocampus
	#   - 18: Left-Amygdala
	#   - 53: Right-Hippocampus
	#   - 54: Right-Amygdala
	#   Cortical ribbon:
	#   - within(a,1000,3000): ctx-lh-[all], ctx-rh-[all]

	# White Matter:
	#   - 2: Left-Cerebral-White-Matter
	#   - 7: Left-Cerebellum-White-Matter
	#   - 41: Right-Cerebral-White-Matter
	#   - 46: Right-Cerebellum-White-Matter
	#   - 251: CC_Posterior
	#   - 252: CC_Mid_Posterior
	#   - 253: CC_Central
	#   - 254: CC_Mid_Anterior
	#   - 255: CC_Anterior

	# CSF:
	#   - 4: Left-Lateral-Ventricle
	#   - 14: 3rd-Ventricle
	#   - 43: Right-Lateral-Ventricle


	# everything labeled in FS, followed by resampling to the BOLD resolution
	3dcalc -a aparc+aseg.nii \
	-expr 'not(equals(a,0))' \
	-prefix aparc+aseg.INBRAINMASK_ero0.nii

	3dresample -rmode NN -master ${masterimg} -prefix aparc+aseg.INBRAINMASK_ero0_EPI.nii -inset aparc+aseg.INBRAINMASK_ero0.nii

	# the major WM compartments, with 4 erosions at the T1 resolution followed by resampling to the BOLD resolution
	3dcalc -a aparc+aseg.nii \
	-expr 'equals(a,2)+equals(a,7)+equals(a,41)+equals(a,46)+equals(a,251)+equals(a,252)+equals(a,253)+equals(a,254)+equals(a,255)' \
	-prefix aparc+aseg.WMMASK_ero0.nii

	3dcalc -a aparc+aseg.WMMASK_ero0.nii -b a+i -c a-i -d a+j -e a-j -f a+k -g a-k \
	-expr 'a*(1-amongst(0,b,c,d,e,f,g))' \
	-prefix aparc+aseg.WMMASK_ero1.nii

	3dcalc -a aparc+aseg.WMMASK_ero1.nii -b a+i -c a-i -d a+j -e a-j -f a+k -g a-k \
	-expr 'a*(1-amongst(0,b,c,d,e,f,g))' \
	-prefix aparc+aseg.WMMASK_ero2.nii

	3dcalc -a aparc+aseg.WMMASK_ero2.nii -b a+i -c a-i -d a+j -e a-j -f a+k -g a-k \
	-expr 'a*(1-amongst(0,b,c,d,e,f,g))' \
	-prefix aparc+aseg.WMMASK_ero3.nii

	3dcalc -a aparc+aseg.WMMASK_ero3.nii -b a+i -c a-i -d a+j -e a-j -f a+k -g a-k \
	-expr 'a*(1-amongst(0,b,c,d,e,f,g))' \
	-prefix aparc+aseg.WMMASK_ero4.nii

	# 3dresample -rmode NN -master ${masterimg} -prefix aparc+aseg.WMMASK_ero0_EPI.nii -inset aparc+aseg.WMMASK_ero0.nii
	# 3dresample -rmode NN -master ${masterimg} -prefix aparc+aseg.WMMASK_ero1_EPI.nii -inset aparc+aseg.WMMASK_ero1.nii
	# 3dresample -rmode NN -master ${masterimg} -prefix aparc+aseg.WMMASK_ero2_EPI.nii -inset aparc+aseg.WMMASK_ero2.nii
	# 3dresample -rmode NN -master ${masterimg} -prefix aparc+aseg.WMMASK_ero3_EPI.nii -inset aparc+aseg.WMMASK_ero3.nii
	# 3dresample -rmode NN -master ${masterimg} -prefix aparc+aseg.WMMASK_ero4_EPI.nii -inset aparc+aseg.WMMASK_ero4.nii

	# the major CSF compartments, with 4 erosions at the T1 resolution followed by resampling to the BOLD resolution
	3dcalc -a aparc+aseg.nii \
	-expr 'equals(a,4)+equals(a,43)+equals(a,14)' \
	-prefix aparc+aseg.CSFMASK_ero0.nii

	3dcalc -a aparc+aseg.CSFMASK_ero0.nii -b a+i -c a-i -d a+j -e a-j -f a+k -g a-k \
	-expr 'a*(1-amongst(0,b,c,d,e,f,g))' \
	-prefix aparc+aseg.CSFMASK_ero1.nii

	3dcalc -a aparc+aseg.CSFMASK_ero1.nii -b a+i -c a-i -d a+j -e a-j -f a+k -g a-k \
	-expr 'a*(1-amongst(0,b,c,d,e,f,g))' \
	-prefix aparc+aseg.CSFMASK_ero2.nii

	3dcalc -a aparc+aseg.CSFMASK_ero2.nii -b a+i -c a-i -d a+j -e a-j -f a+k -g a-k \
	-expr 'a*(1-amongst(0,b,c,d,e,f,g))' \
	-prefix aparc+aseg.CSFMASK_ero3.nii

	3dcalc -a aparc+aseg.CSFMASK_ero3.nii -b a+i -c a-i -d a+j -e a-j -f a+k -g a-k \
	-expr 'a*(1-amongst(0,b,c,d,e,f,g))' \
	-prefix aparc+aseg.CSFMASK_ero4.nii

	# 3dresample -rmode NN -master ${masterimg} -prefix aparc+aseg.CSFMASK_ero0_EPI.nii -inset aparc+aseg.CSFMASK_ero0.nii
	# 3dresample -rmode NN -master ${masterimg} -prefix aparc+aseg.CSFMASK_ero1_EPI.nii -inset aparc+aseg.CSFMASK_ero1.nii
	# 3dresample -rmode NN -master ${masterimg} -prefix aparc+aseg.CSFMASK_ero2_EPI.nii -inset aparc+aseg.CSFMASK_ero2.nii
	# 3dresample -rmode NN -master ${masterimg} -prefix aparc+aseg.CSFMASK_ero3_EPI.nii -inset aparc+aseg.CSFMASK_ero3.nii
	# 3dresample -rmode NN -master ${masterimg} -prefix aparc+aseg.CSFMASK_ero4_EPI.nii -inset aparc+aseg.CSFMASK_ero4.nii

	# the gray matter ribbon (amygdala and hippocampus need to be added - 17 18 53 54
	3dcalc -a aparc+aseg.nii \
	-expr 'within(a,1000,3000)+equals(a,17)+equals(a,18)+equals(a,53)+equals(a,54)' \
	-prefix aparc+aseg.GM_RIBBONMASK_ero0.nii

	# the amygdala: left=18, right=54
	3dcalc -a aparc+aseg.nii \
	-expr 'equals(a,18)+equals(a,54)' \
	-prefix aparc+aseg.GM_AMYGMASK_ero0.nii

	# Brodmann areas - motor:
	# BA 4a - primary motor area (anterior)
	# BA 4p - primary motor area (posterier)
	# BA 6 - pre-motor area

#	3dcalc -a aparc+aseg.nii \
#	-expr 'equals(a,404)' \
#	-prefix aparc+aseg.GM_BROD4a_ero0.nii
#
#	3dcalc -a aparc+aseg.nii \
#	-expr 'equals(a,405)' \
#	-prefix aparc+aseg.GM_BROD4p_ero0.nii
#
#	3dcalc -a aparc+aseg.nii \
#	-expr 'equals(a,406)' \
#	-prefix aparc+aseg.GM_BROD6_ero0.nii
#
#	3dcalc -a aparc+aseg.nii \
#	-expr 'equals(a,404)+equals(a,405)' \
#	-prefix aparc+aseg.GM_BROD4ap_ero0.nii
#
#	3dcalc -a aparc+aseg.nii \
#	-expr 'equals(a,404)+equals(a,405)+equals(a,406)' \
#	-prefix aparc+aseg.GM_BROD4ap6_ero0.nii

#mri_label2vol --help

	# 3dresample -rmode NN -master ${masterimg} -prefix aparc+aseg.GM_RIBBONMASK_ero0_EPI.nii -inset aparc+aseg.GM_RIBBONMASK_ero0.nii

	# the cerebellum
	3dcalc -a aparc+aseg.nii \
	-expr 'equals(a,47)+equals(a,8)' \
	-prefix aparc+aseg.GM_CBLMMASK_ero0.nii

	3dcalc -a aparc+aseg.GM_CBLMMASK_ero0.nii -b a+i -c a-i -d a+j -e a-j -f a+k -g a-k \
	-expr 'a*(1-amongst(0,b,c,d,e,f,g))' \
	-prefix aparc+aseg.GM_CBLMMASK_ero1.nii

	3dcalc -a aparc+aseg.GM_CBLMMASK_ero1.nii -b a+i -c a-i -d a+j -e a-j -f a+k -g a-k \
	-expr 'a*(1-amongst(0,b,c,d,e,f,g))' \
	-prefix aparc+aseg.GM_CBLMMASK_ero2.nii

	# 3dresample -rmode NN -master ${masterimg} -prefix aparc+aseg.GM_CBLMMASK_ero0_EPI.nii -inset aparc+aseg.GM_CBLMMASK_ero0.nii
	# 3dresample -rmode NN -master ${masterimg} -prefix aparc+aseg.GM_CBLMMASK_ero1_EPI.nii -inset aparc+aseg.GM_CBLMMASK_ero1.nii
	# 3dresample -rmode NN -master ${masterimg} -prefix aparc+aseg.GM_CBLMMASK_ero2_EPI.nii -inset aparc+aseg.GM_CBLMMASK_ero2.nii

	# the subcortical nuclei
	3dcalc -a aparc+aseg.nii \
	-expr 'equals(a,11)+equals(a,12)+equals(a,10)+equals(a,49)+equals(a,50)+equals(a,51)' \
	-prefix aparc+aseg.GM_SCMASK_ero0.nii

	3dcalc -a aparc+aseg.GM_SCMASK_ero0.nii -b a+i -c a-i -d a+j -e a-j -f a+k -g a-k \
	-expr 'a*(1-amongst(0,b,c,d,e,f,g))' \
	-prefix aparc+aseg.GM_SCMASK_ero1.nii

	3dcalc -a aparc+aseg.GM_SCMASK_ero1.nii -b a+i -c a-i -d a+j -e a-j -f a+k -g a-k \
	-expr 'a*(1-amongst(0,b,c,d,e,f,g))' \
	-prefix aparc+aseg.GM_SCMASK_ero2.nii

	# 3dresample -rmode NN -master ${masterimg} -prefix aparc+aseg.GM_SCMASK_ero0_EPI.nii -inset aparc+aseg.GM_SCMASK_ero0.nii
	# 3dresample -rmode NN -master ${masterimg} -prefix aparc+aseg.GM_SCMASK_ero1_EPI.nii -inset aparc+aseg.GM_SCMASK_ero1.nii
	# 3dresample -rmode NN -master ${masterimg} -prefix aparc+aseg.GM_SCMASK_ero2_EPI.nii -inset aparc+aseg.GM_SCMASK_ero2.nii

	# all gray matter
	3dcalc -a aparc+aseg.nii \
	-expr 'within(a,1000,3000)+equals(a,17)+equals(a,18)+equals(a,53)+equals(a,54)+equals(a,47)+equals(a,8)+equals(a,11)+equals(a,12)+equals(a,10)+equals(a,49)+equals(a,50)+equals(a,51)' \
	-prefix aparc+aseg.GM_ALLMASK_ero0.nii

#	3dresample -rmode NN -master ${masterimg} -prefix aparc+aseg.GM_ALLMASK_ero0_EPI.nii -inset aparc+aseg.GM_ALLMASK_ero0.nii


	echo ----------------------------------------------------------
	echo ----------------------------------------------------------
	echo ALL DONE MAKING MASKS
	echo ----------------------------------------------------------
	echo ----------------------------------------------------------

# popd
done
























