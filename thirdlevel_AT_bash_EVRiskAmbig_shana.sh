#!/bin/sh
 
# --- BEGIN GLOBAL DIRECTIVE --
#$ -S /bin/sh
#$ -o $HOME/$JOB_NAME.$JOB_ID.out
#$ -e $HOME/$JOB_NAME.$JOB_ID.out
#$ -m ea
# -- END GLOBAL DIRECTIVE --
 
# -- BEGIN PRE-USER --
#Name of experiment whose data you want to access
EXPERIMENT=DECIDE.01

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


scriptdir=${EXPERIMENT}/Scripts/AT_scripts/shana
designfile1=thirdlevel_AT_design_AmbigVRisk_GM_asOneGroup_wGroupsAlone_fixedFX_wResponse.fsf
designfile2=thirdlevel_AT_design_Risk_GM_asOneGroup_wGroupsAlone_wResponse.fsf
designfile3=thirdlevel_AT_design_Ambig_GM_asOneGroup_wGroupsAlone_wResponse.fsf
designfile4=thirdlevel_AT_design_RiskVAmbig_GM_asOneGroup_wGroupsAlone_wResponse.fsf


FSLDIR=/usr/local/packages/fsl-5.0.9
export FSLDIR
source ${FSLDIR}/etc/fslconf/fsl.sh 

#feat ${scriptdir}/${designfile1}
#feat ${scriptdir}/${designfile2}
#feat ${scriptdir}/${designfile3}
feat ${scriptdir}/${designfile4}

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
