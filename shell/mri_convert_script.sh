#!/usr/bin/bash

export FREESURFER_HOME=/home/tue/jheunis/freesurfer
export SUBJECTS_DIR=$FREESURFER_HOME/subjects
source $FREESURFER_HOME/SetUpFreeSurfer.sh

cd /home/tue/jheunis/
filename=participants_wo_heading.tsv
declare -a participantsArray
participantsArray=(`cat "$filename"`)

for i in "${participantsArray[@]}"
do
	mkdir "/home/tue/jheunis/fs_derivatives/$i"
	cp -p "/home/tue/jheunis/freesurfer/subjects/$i/mri/aparc+aseg.mgz" "/home/tue/jheunis/fs_derivatives/$i/"
	cd "/home/tue/jheunis/fs_derivatives/$i/"
	mri_convert aparc+aseg.mgz aparc+aseg.nii
done