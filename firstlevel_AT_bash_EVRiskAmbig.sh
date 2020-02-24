#!/bin/sh
 
# --- BEGIN GLOBAL DIRECTIVE --
#$ -S /bin/sh
#$ -o $HOME/$JOB_NAME.$JOB_ID.out
#$ -e $HOME/$JOB_NAME.$JOB_ID.out
#$ -m ea
# -- END GLOBAL DIRECTIVE --
 
# -- BEGIN PRE-USER --
#Name of experiment whose data you want to access
EXPERIMENT=${EXPERIMENT:?"Experiment not provided"}
 
EXPERIMENT=`findexp $EXPERIMENT`
EXPERIMENT=${EXPERIMENT:?"Returned NULL Experiment"}
 
if [ $EXPERIMENT = "ERROR" ]
then
        exit 32
else
#Timestamp
echo "----JOB [$JOB_NAME.$JOB_ID] START [`date`] on HOST [$HOSTNAME]----"
# -- END PRE-USER -


#loads the fsl program
#export FSLDIR=/usr/local/packages/fsl
#. ${FSLDIR}/etc/fslconf/fsl.sh

#1st var is suject number
#2nd var is biac ID number 
#3rd var is func series number 
#4th var anat series number
#5th var is behavioral list number
#qsub -v EXPERIMENT=DECIDE.01 fsl_1st 4563 18436 5 12 1


SUBJnum=$1
BIACID=$2
Date=$3
LIST=$4
HIRES=$5
BEHNUM=$6

FSLNIFTIDIR=$EXPERIMENT/Analysis/BIDS/data_fmriprep/fmriprep/sub-$BIACID/ses-one/func
FSLDATADIR=$EXPERIMENT/Analysis/BIDS/AmbiguityTolerance/fmriprep_EVRiskAmbig_2020/Level1/sub-$BIACID
BEHAV_DATADIR=$EXPERIMENT/Analysis/BIDS/AmbiguityTolerance/Timing
ANATFILE=$EXPERIMENT/Analysis/BIDS/AmbiguityTolerance/anat/sub-${BIACID}/sub-${BIACID}_masked_space-MNI152NLin6Asym_desc-preproc_T1w.nii.gz
RISKY=${BEHAV_DATADIR}/AT_${BIACID}_Risky_${BEHNUM}.txt
AMBIG=${BEHAV_DATADIR}//AT_${BIACID}_Ambig_${BEHNUM}.txt
ExpVal=${BEHAV_DATADIR}/AT_${BIACID}_EV_${BEHNUM}.txt
OUTPUT=${FSLDATADIR}/${BIACID}_AT${BEHNUM}
DATA=${FSLNIFTIDIR}/sub-${BIACID}_ses-one_task-AT_run-0${BEHNUM}_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz
TEMPLATE=$EXPERIMENT/Scripts/AT_scripts/shana/firstlevel_AT_design_EVRiskAmbig.fsf

mkdir -p ${FSLDATADIR} 

for i in $TEMPLATE; do
echo $i
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@RISKY@'$RISKY'@g' \
 -e 's@AMBIG@'$AMBIG'@g' \
 -e 's@ExpVal@'$ExpVal'@g' \
 -e 's@DATA@'$DATA'@g' <$i> ${FSLDATADIR}/${BIACID}_AT${BEHNUM}.fsf
done

feat ${FSLDATADIR}/${BIACID}_AT${BEHNUM}.fsf


# **********************************************************
# -- BEGIN POST-USER --
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----"
OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis/BIDS/AmbiguityTolerance/logs}
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER--
