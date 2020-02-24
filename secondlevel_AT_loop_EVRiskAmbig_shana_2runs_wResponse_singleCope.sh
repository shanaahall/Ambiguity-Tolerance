#!/bin/sh
 
# This is a BIAC template script for jobs on the cluster
# You have to provide the Experiment on command line  
# when you submit the job the cluster.
#
# >  qsub -v EXPERIMENT=Dummy.01  script.sh args
#
# There are 2 USER sections 
#  1. USER DIRECTIVE: If you want mail notifications when
#     your job is completed or fails you need to set the 
#     correct email address.
#		   
#  2. USER SCRIPT: Add the user script in this section.
#     Within this section you can access your experiment 
#     folder using $EXPERIMENT. All paths are relative to this variable
#     eg: $EXPERIMENT/Data $EXPERIMENT/Analysis	
#     By default all terminal output is routed to the " Analysis "
#     folder under the Experiment directory i.e. $EXPERIMENT/Analysis
#     To change this path, set the OUTDIR variable in this section
#     to another location under your experiment folder
#     eg: OUTDIR=$EXPERIMENT/Analysis/GridOut 	
#     By default on successful completion the job will return 0
#     If you need to set another return code, set the RETURNCODE
#     variable in this section. To avoid conflict with system return 
#     codes, set a RETURNCODE higher than 100.
#     eg: RETURNCODE=110
#     Arguments to the USER SCRIPT are accessible in the usual fashion
#     eg:  $1 $2 $3
# The remaining sections are setup related and don't require
# modifications for most scripts. They are critical for access
# to your data  	 
 
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
# -- END PRE-USER --
# **********************************************************
 
# -- BEGIN USER DIRECTIVE --
# Send notifications to the following address
#$ -M sah49@duke.edu
 
# -- END USER DIRECTIVE --
 
# -- BEGIN USER SCRIPT --
# User script goes here

#A script for automatically submitting LA scripts using a text file sourced from the DECIDE MRI log
#As configured, run in cluster and this will take up many nodes, but automates the submission of Preprocessing FEATs

INPUTDIR=/mnt/BIAC/munin2.dhe.duke.edu/Meade/DECIDE.01/Scripts/Lookup
cd $INPUTDIR
LOOKUPTABLE=decide_AT_batch_lookup_singlesubj.txt

max1=`cat ${LOOKUPTABLE} | wc -l`
max2=${max1}-1
#Adjust range of variable a below to set the number of things you want to run at once

for((a=1; a<=${max2}; a++))
do

	#Grab variables by line from decide_batch_lookup.txt
	#Assign columns below (aka what is in {print $x} based on the column order in decide_batch_lookup.txt	
	SUBJ=`awk -v b="$a" 'NR == b+1 {print $1}' ${LOOKUPTABLE}`
	BIAC=`awk -v b="$a" 'NR == b+1 {print $2}' ${LOOKUPTABLE}`
	DATE=`awk -v b="$a" 'NR == b+1 {print $3}' ${LOOKUPTABLE}`
	AT1=`awk -v b="$a" 'NR == b+1 {print $8}' ${LOOKUPTABLE}`
	AT2=`awk -v b="$a" 'NR == b+1 {print $9}' ${LOOKUPTABLE}`
	AT3=`awk -v b="$a" 'NR == b+1 {print $10}' ${LOOKUPTABLE}`
	INCLUDE=`awk -v b="$a" 'NR == b+1 {print $16}' ${LOOKUPTABLE}`

	if (($INCLUDE == 1)); then	
		#The lines below submit jobs into the pre-existing pipeline
		cd /mnt/BIAC/munin2.dhe.duke.edu/Meade/DECIDE.01/Scripts/AT_scripts/shana
		qsub -v EXPERIMENT=DECIDE.01 secondlevel_AT_bash_EVRiskAmbig_shana_2runs_wResponse_singleCope.sh $SUBJ $BIAC $AT1 $AT2 $AT3 1 2 3
	
		#can sleep to avoid crowding cluster 
		#sleep 30s
	fi	

	cd $INPUTDIR
done

# -- END USER SCRIPT -- #
 
# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
sub_OUTDIR_sub=${sub_OUTDIR_sub:-$EXPERIMENT/Analysis/BIDS/AmbiguityTolerance/logs}
mv $HOME/$JOB_NAME.$JOB_ID.out $sub_OUTDIR_sub/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER--
