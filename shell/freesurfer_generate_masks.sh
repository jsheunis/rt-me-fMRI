#!/usr/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --partition=elec.default.q
#SBATCH --error=slurm-%j.err
#SBATCH --output=slurm-%j.out
#SBATCH --time=24:00:00

export FREESURFER_HOME=/home/tue/jheunis/freesurfer
export SUBJECTS_DIR=$FREESURFER_HOME/subjects
source $FREESURFER_HOME/SetUpFreeSurfer.sh

FS_DRIV=/home/tue/jheunis/fs_derivatives
SUB="sub-019"

instruction1="--label lh.BA4a_exvivo.label --temp $SUBJECTS_DIR/$SUB/mri/orig.mgz --identity --o $FS_DRIV/$SUB/BA_4a_lh.nii"
instruction2="--label lh.BA4p_exvivo.label --temp $SUBJECTS_DIR/$SUB/mri/orig.mgz --identity --o $FS_DRIV/$SUB/BA_4p_lh.nii"
instruction3="--label rh.BA4a_exvivo.label --temp $SUBJECTS_DIR/$SUB/mri/orig.mgz --identity --o $FS_DRIV/$SUB/BA_4a_rh.nii"
instruction4="--label rh.BA4p_exvivo.label --temp $SUBJECTS_DIR/$SUB/mri/orig.mgz --identity --o $FS_DRIV/$SUB/BA_4p_rh.nii"
instruction5="--label lh.BA6_exvivo.label --temp $SUBJECTS_DIR/$SUB/mri/orig.mgz --identity --o $FS_DRIV/$SUB/BA_6_lh.nii"
instruction6="--label rh.BA6_exvivo.label --temp $SUBJECTS_DIR/$SUB/mri/orig.mgz --identity --o $FS_DRIV/$SUB/BA_6_rh.nii"

cd "$SUBJECTS_DIR/$SUB/label/"
mri_label2vol $instruction1
mri_label2vol $instruction2
mri_label2vol $instruction3
mri_label2vol $instruction4
mri_label2vol $instruction5
mri_label2vol $instruction6


#
#mri_label2vol --label lh.BA4a_exvivo.label --temp $SUBJECTS_DIR/sub-001/mri/orig.mgz --identity --o BA_4a_lh.nii
#
#mri_label2vol
#  --label rh.BA4a_exvivo.label
#  --temp $SUBJECTS_DIR/bert/orig
#  --identity
#  --o BA_4a_rh.nii


#lh.BA4p_exvivo.label
