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

source /etc/biac_sge.sh
 
EXPERIMENT=`biacmount $EXPERIMENT`
EXPERIMENT=${EXPERIMENT:?"Returned NULL Experiment"}
 
if [ $EXPERIMENT = "ERROR" ]
then
        exit 32
else
#Timestamp
echo "----JOB [$JOB_NAME.$JOB_ID] START [`date`] on HOST [$HOSTNAME]----"
# -- END PRE-USER -

# -- BEGIN USER DIRECTIVE --
# Send notifications to the following address
#$ -M sah49@duke.edu
 
# -- END USER DIRECTIVE --
 
# -- BEGIN USER SCRIPT --
# User script goes here

#loads the fsl program
#export FSLDIR=/usr/local/packages/fsl
#. ${FSLDIR}/etc/fslconf/fsl.sh


#1st var is suject number
#2nd var is biac ID number 
#3rd var is func series number 1 
#4th var is func series number 2
#5th var is func series number 3 
#6th var is the first run num (should be 1)
#7th var is the second run num (should be 2)
#8th var is the third run num (should be 3)
#qsub -v EXPERIMENT=DECIDE.01 secondlevel_LA_bash.sh 

SUBJnum=$1
BIACID=$2
AT1=$3
AT2=$4
AT3=$5
RUN1=$6
RUN2=$7
RUN3=$8


FSL_1stDATADIR=$EXPERIMENT/Analysis/BIDS/AmbiguityTolerance/fmriprep_EVRiskAmbig_2020/Level1_wResp/sub-$BIACID
OUTPUT=$EXPERIMENT/Analysis/BIDS/AmbiguityTolerance/fmriprep_EVRiskAmbig_2020/Level2_wResp/sub-${BIACID}
TEMPLATE=$EXPERIMENT/Scripts/AT_scripts/shana
RunFile_01=${FSL_1stDATADIR}/${BIACID}_AT${RUN1}.feat
RunFile_02=${FSL_1stDATADIR}/${BIACID}_AT${RUN2}.feat
RunFile_03=${FSL_1stDATADIR}/${BIACID}_AT${RUN3}.feat

mkdir -p ${OUTPUT}

cd ${TEMPLATE}
for i in 'secondlevel_AT_design_EVRiskAmbig_shana_1run_wResp.fsf'; do
sed -e 's@OUTPUT@'$OUTPUT'@g'\
 -e 's@RunFile_01@'$RunFile_01'@g'\
 -e 's@RunFile_02@'$RunFile_02'@g' <$i> ${OUTPUT}/${BIACID}.fsf
done

FSLDIR=/usr/local/packages/fsl-5.0.9
export FSLDIR
source ${FSLDIR}/etc/fslconf/fsl.sh 

feat ${OUTPUT}/${BIACID}.fsf

# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER --
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----"
OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis/BIDS/AmbiguityTolerance/logs}
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- #
