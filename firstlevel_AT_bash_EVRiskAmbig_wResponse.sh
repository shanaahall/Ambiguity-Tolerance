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
FSLDATADIR=$EXPERIMENT/Analysis/BIDS/AmbiguityTolerance/fmriprep_EVRiskAmbig_2020/Level1_wResp/sub-$BIACID
BEHAV_DATADIR=$EXPERIMENT/Analysis/BIDS/AmbiguityTolerance/Timing
ANATFILE=$EXPERIMENT/Analysis/BIDS/AmbiguityTolerance/anat/sub-${BIACID}/sub-${BIACID}_masked_space-MNI152NLin6Asym_desc-preproc_T1w.nii.gz
RISKYCERT=${BEHAV_DATADIR}/AT_${BIACID}_Risky_certain_${BEHNUM}.txt
RISKYUNCERT=${BEHAV_DATADIR}/AT_${BIACID}_Risky_uncertain_${BEHNUM}.txt
AMBIGCERT=${BEHAV_DATADIR}//AT_${BIACID}_Ambig_certain_${BEHNUM}.txt
AMBIGUNCERT=${BEHAV_DATADIR}//AT_${BIACID}_Ambig_uncertain_${BEHNUM}.txt
RISKYMISSED=${BEHAV_DATADIR}/AT_${BIACID}_Risky_missed_${BEHNUM}.txt
AMBIGMISSED=${BEHAV_DATADIR}//AT_${BIACID}_Ambig_missed_${BEHNUM}.txt
ExpVal=${BEHAV_DATADIR}/AT_${BIACID}_EV_${BEHNUM}.txt
OUTPUT=${FSLDATADIR}/${BIACID}_AT${BEHNUM}
DATA=${FSLNIFTIDIR}/sub-${BIACID}_ses-one_task-AT_run-0${BEHNUM}_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz
TEMPLATE=$EXPERIMENT/Scripts/AT_scripts/shana/firstlevel_AT_design_EVRiskAmbig_wResponse.fsf
OUTFSF=${FSLDATADIR}/${BIACID}_AT${BEHNUM}.fsf

mkdir -p ${FSLDATADIR} 

for i in $TEMPLATE; do
echo $i
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@DATA@'$DATA'@g' <$i> ${OUTFSF}
done

for i in $OUTFSF; do
echo $i
if [ -f "$RISKYCERT" ]; then
    sed -e 's@RISKYCERT@'$RISKYCERT'@g' <$i> ${OUTFSF}.tmp && mv ${OUTFSF}.tmp ${OUTFSF} #If the onset file exists, sub the name of the onset file into the design file
else # if the onset file does not exist:
    EVLINENUM=$(grep -rn 'RISKYCERT' $i | awk -F ":" '{print $1}') #Find the line number where the EV number is defined
    EVLINE=$(sed -n ${EVLINENUM}'p' $i) #Go to that line
    EVNUM=$(echo ${EVLINE:15:1}) #Extract the EV number
    let EVNUMCON=$EVNUM*2-1
    sed -e 's@set fmri(shape'$EVNUM') 3@set fmri(shape'$EVNUM') 10@g' \
-e 's@set fmri(convolve'$EVNUM') 3@set fmri(convolve'$EVNUM') 0@g' \
-e 's@set fmri(con_real1.'$EVNUMCON') 1.0@set fmri(con_real1.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real2.'$EVNUMCON') 1.0@set fmri(con_real2.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real3.'$EVNUMCON') 1.0@set fmri(con_real3.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real4.'$EVNUMCON') 1.0@set fmri(con_real4.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real3.'$EVNUMCON') -1.0@set fmri(con_real3.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real4.'$EVNUMCON') -1.0@set fmri(con_real4.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_orig1.'$EVNUM') 1.0@set fmri(con_orig1.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig2.'$EVNUM') 1.0@set fmri(con_orig2.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig3.'$EVNUM') 1.0@set fmri(con_orig3.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig4.'$EVNUM') 1.0@set fmri(con_orig4.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig3.'$EVNUM') -1.0@set fmri(con_orig3.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig4.'$EVNUM') -1.0@set fmri(con_orig4.'$EVNUM') 0.0@g' \
-e '/# Custom EV file (EV '$EVNUM')/d' \
-e '/set fmri(custom'$EVNUM') "RISKYCERT"/d' <$i> ${OUTFSF}.tmp && mv ${OUTFSF}.tmp ${OUTFSF} #Make the onset file equal 10 (Empty). Make the convolution 0 (None). Delete the Custom EV file lines. 
fi

if [ -f "$RISKYUNCERT" ]; then
    sed -e 's@RISKYUNCERT@'$RISKYUNCERT'@g' <$i> ${OUTFSF}.tmp && mv ${OUTFSF}.tmp ${OUTFSF}
else
    EVLINENUM=$(grep -rn 'RISKYUNCERT' $i | awk -F ":" '{print $1}')
    EVLINE=$(sed -n ${EVLINENUM}'p' $i)
    EVNUM=$(echo ${EVLINE:15:1})
    let EVNUMCON=$EVNUM*2-1
    sed -e 's@set fmri(shape'$EVNUM') 3@set fmri(shape'$EVNUM') 10@g' \
-e 's@set fmri(convolve'$EVNUM') 3@set fmri(convolve'$EVNUM') 0@g' \
-e 's@set fmri(con_real1.'$EVNUMCON') 1.0@set fmri(con_real1.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real2.'$EVNUMCON') 1.0@set fmri(con_real2.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real3.'$EVNUMCON') 1.0@set fmri(con_real3.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real4.'$EVNUMCON') 1.0@set fmri(con_real4.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real3.'$EVNUMCON') -1.0@set fmri(con_real3.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real4.'$EVNUMCON') -1.0@set fmri(con_real4.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_orig1.'$EVNUM') 1.0@set fmri(con_orig1.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig2.'$EVNUM') 1.0@set fmri(con_orig2.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig3.'$EVNUM') 1.0@set fmri(con_orig3.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig4.'$EVNUM') 1.0@set fmri(con_orig4.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig3.'$EVNUM') -1.0@set fmri(con_orig3.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig4.'$EVNUM') -1.0@set fmri(con_orig4.'$EVNUM') 0.0@g' \
-e '/# Custom EV file (EV '$EVNUM')/d' \
-e '/set fmri(custom'$EVNUM') "RISKYUNCERT"/d' <$i> ${OUTFSF}.tmp && mv ${OUTFSF}.tmp ${OUTFSF}
fi
done

if [ -f "$AMBIGCERT" ]; then
    sed -e 's@AMBIGCERT@'$AMBIGCERT'@g' <$i> ${OUTFSF}.tmp && mv ${OUTFSF}.tmp ${OUTFSF}
else
    EVLINENUM=$(grep -rn 'AMBIGCERT' $i | awk -F ":" '{print $1}')
    EVLINE=$(sed -n ${EVLINENUM}'p' $i)
    EVNUM=$(echo ${EVLINE:15:1})
    let EVNUMCON=$EVNUM*2-1
    sed -e 's@set fmri(shape'$EVNUM') 3@set fmri(shape'$EVNUM') 10@g' \
-e 's@set fmri(convolve'$EVNUM') 3@set fmri(convolve'$EVNUM') 0@g' \
-e 's@set fmri(con_real1.'$EVNUMCON') 1.0@set fmri(con_real1.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real2.'$EVNUMCON') 1.0@set fmri(con_real2.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real3.'$EVNUMCON') 1.0@set fmri(con_real3.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real4.'$EVNUMCON') 1.0@set fmri(con_real4.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real3.'$EVNUMCON') -1.0@set fmri(con_real3.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real4.'$EVNUMCON') -1.0@set fmri(con_real4.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_orig1.'$EVNUM') 1.0@set fmri(con_orig1.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig2.'$EVNUM') 1.0@set fmri(con_orig2.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig3.'$EVNUM') 1.0@set fmri(con_orig3.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig4.'$EVNUM') 1.0@set fmri(con_orig4.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig3.'$EVNUM') -1.0@set fmri(con_orig3.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig4.'$EVNUM') -1.0@set fmri(con_orig4.'$EVNUM') 0.0@g' \
-e '/# Custom EV file (EV '$EVNUM')/d' \
-e '/set fmri(custom'$EVNUM') "AMBIGCERT"/d' <$i> ${OUTFSF}.tmp && mv ${OUTFSF}.tmp ${OUTFSF}
fi

if [ -f "$AMBIGUNCERT" ]; then
    sed -e 's@AMBIGUNCERT@'$AMBIGUNCERT'@g' <$i> ${OUTFSF}.tmp && mv ${OUTFSF}.tmp ${OUTFSF}
else
    EVLINENUM=$(grep -rn 'AMBIGUNCERT' $i | awk -F ":" '{print $1}')
    EVLINE=$(sed -n ${EVLINENUM}'p' $i)
    EVNUM=$(echo ${EVLINE:15:1})
    let EVNUMCON=$EVNUM*2-1
    sed -e 's@set fmri(shape'$EVNUM') 3@set fmri(shape'$EVNUM') 10@g' \
-e 's@set fmri(convolve'$EVNUM') 3@set fmri(convolve'$EVNUM') 0@g' \
-e 's@set fmri(con_real1.'$EVNUMCON') 1.0@set fmri(con_real1.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real2.'$EVNUMCON') 1.0@set fmri(con_real2.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real3.'$EVNUMCON') 1.0@set fmri(con_real3.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real4.'$EVNUMCON') 1.0@set fmri(con_real4.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real3.'$EVNUMCON') -1.0@set fmri(con_real3.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real4.'$EVNUMCON') -1.0@set fmri(con_real4.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_orig1.'$EVNUM') 1.0@set fmri(con_orig1.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig2.'$EVNUM') 1.0@set fmri(con_orig2.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig3.'$EVNUM') 1.0@set fmri(con_orig3.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig4.'$EVNUM') 1.0@set fmri(con_orig4.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig3.'$EVNUM') -1.0@set fmri(con_orig3.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig4.'$EVNUM') -1.0@set fmri(con_orig4.'$EVNUM') 0.0@g' \
-e '/# Custom EV file (EV '$EVNUM')/d' \
-e '/set fmri(custom'$EVNUM') "AMBIGUNCERT"/d' <$i> ${OUTFSF}.tmp && mv ${OUTFSF}.tmp ${OUTFSF}
fi 

if [ -f "$RISKYMISSED" ]; then
    sed -e 's@RISKYMISSED@'$RISKYMISSED'@g' <$i> ${OUTFSF}.tmp && mv ${OUTFSF}.tmp ${OUTFSF}
else
    EVLINENUM=$(grep -rn 'RISKYMISSED' $i | awk -F ":" '{print $1}')
    EVLINE=$(sed -n ${EVLINENUM}'p' $i)
    EVNUM=$(echo ${EVLINE:15:1})
    let EVNUMCON=$EVNUM*2-1
    sed -e 's@set fmri(shape'$EVNUM') 3@set fmri(shape'$EVNUM') 10@g' \
-e 's@set fmri(convolve'$EVNUM') 3@set fmri(convolve'$EVNUM') 0@g' \
-e 's@set fmri(con_real1.'$EVNUMCON') 1.0@set fmri(con_real1.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real2.'$EVNUMCON') 1.0@set fmri(con_real2.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real3.'$EVNUMCON') 1.0@set fmri(con_real3.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real4.'$EVNUMCON') 1.0@set fmri(con_real4.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real3.'$EVNUMCON') -1.0@set fmri(con_real3.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real4.'$EVNUMCON') -1.0@set fmri(con_real4.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_orig1.'$EVNUM') 1.0@set fmri(con_orig1.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig2.'$EVNUM') 1.0@set fmri(con_orig2.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig3.'$EVNUM') 1.0@set fmri(con_orig3.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig4.'$EVNUM') 1.0@set fmri(con_orig4.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig3.'$EVNUM') -1.0@set fmri(con_orig3.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig4.'$EVNUM') -1.0@set fmri(con_orig4.'$EVNUM') 0.0@g' \
-e '/# Custom EV file (EV '$EVNUM')/d' \
-e '/set fmri(custom'$EVNUM') "RISKYMISSED"/d' <$i> ${OUTFSF}.tmp && mv ${OUTFSF}.tmp ${OUTFSF}
fi 

if [ -f "$AMBIGMISSED" ]; then
    sed -e 's@AMBIGMISSED@'$AMBIGMISSED'@g' <$i> ${OUTFSF}.tmp && mv ${OUTFSF}.tmp ${OUTFSF} 
else
    EVLINENUM=$(grep -rn 'AMBIGMISSED' $i | awk -F ":" '{print $1}')
    EVLINE=$(sed -n ${EVLINENUM}'p' $i)
    EVNUM=$(echo ${EVLINE:15:1})
    let EVNUMCON=$EVNUM*2-1
    sed -e 's@set fmri(shape'$EVNUM') 3@set fmri(shape'$EVNUM') 10@g' \
-e 's@set fmri(convolve'$EVNUM') 3@set fmri(convolve'$EVNUM') 0@g' \
-e 's@set fmri(con_real1.'$EVNUMCON') 1.0@set fmri(con_real1.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real2.'$EVNUMCON') 1.0@set fmri(con_real2.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real3.'$EVNUMCON') 1.0@set fmri(con_real3.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real4.'$EVNUMCON') 1.0@set fmri(con_real4.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real3.'$EVNUMCON') -1.0@set fmri(con_real3.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_real4.'$EVNUMCON') -1.0@set fmri(con_real4.'$EVNUMCON') 0.0@g' \
-e 's@set fmri(con_orig1.'$EVNUM') 1.0@set fmri(con_orig1.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig2.'$EVNUM') 1.0@set fmri(con_orig2.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig3.'$EVNUM') 1.0@set fmri(con_orig3.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig4.'$EVNUM') 1.0@set fmri(con_orig4.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig3.'$EVNUM') -1.0@set fmri(con_orig3.'$EVNUM') 0.0@g' \
-e 's@set fmri(con_orig4.'$EVNUM') -1.0@set fmri(con_orig4.'$EVNUM') 0.0@g' \
-e '/# Custom EV file (EV '$EVNUM')/d' \
-e '/set fmri(custom'$EVNUM') "AMBIGMISSED"/d' <$i> ${OUTFSF}.tmp && mv ${OUTFSF}.tmp ${OUTFSF}
fi 



feat ${FSLDATADIR}/${BIACID}_AT${BEHNUM}.fsf
#echo ${FSLDATADIR}/${BIACID}_AT${BEHNUM}.fsf

# **********************************************************
# -- BEGIN POST-USER --
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----"
OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis/BIDS/AmbiguityTolerance/logs}
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER--
