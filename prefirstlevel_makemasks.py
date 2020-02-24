#### IMPORT LIBRARIES ###
import os,string
import numpy as np
import nibabel as nib
from scipy import stats
from scipy import io
import sys
import subprocess
import datetime
import pandas as pd
import shutil


### FUNCTIONS ###

def load_tsv(filename):
    """ This function loads a .tsv file and outputs it. """

    #print('Loading %s' %(filename))
    out=np.loadtxt(filename)
    if out is None:
        out.empty(1,1)

    return out

def get_groups(df,groups):
    """ This function creates groups based on the lookup table. """
    groupdict = dict()
    for grouploopcount,grouploop in enumerate(groups):
        print('getting group %d' %(grouploop))
        for index, row in df.iterrows():
            if row['groupnum'] == grouploop:
                #tempgroup = row['groupnum']
                tempsub = row['biacnum']
                #print('g%d%d' %(tempgroup,tempsub))
                if row['groupnum'] in groupdict:
                    groupdict[grouploop].append('%d' %(tempsub))
                else:
                    groupdict[grouploop] = ['%d' %(tempsub)]

    return groupdict

def save_tsv(filename,data):
    """ This function saves a .tsv file. """

    #print('Saving %s' %(filename))
    np.savetxt(filename,data,fmt='%.8f',delimiter='\t',newline='\n')


### INPUTS ###
def main(argv = sys.argv):

    # Variables that may have to change
    homedir = '/mnt/BIAC/munin2.dhe.duke.edu/Meade/'
    project = 'DECIDE.01'
    scriptdir = os.path.join(homedir,project,'Scripts','')
    bidsdir = os.path.join(homedir,project,'Analysis/BIDS')
    tasks=['rest']
    runs=['1','2','3']
    lookuptable = os.path.join(scriptdir,'Lookup','decide_AT_batch_lookup_singlesubj.txt')
    indirbase=os.path.join(homedir,project,'Analysis','BIDS','data_fmriprep','fmriprep','')
    outdirbase = os.path.join(bidsdir,'AmbiguityTolerance','anat','')

    lookupdf = pd.read_csv(lookuptable,sep='\t')
    for index,row in lookupdf.iterrows():
        if row['include'] == 1:
            biac = row['BIAC']
            biac=str(biac)
            indir = os.path.join(indirbase,'sub-%s'%biac,'anat','')
            outdir = os.path.join(outdirbase,'sub-%s'%biac,'')
            if not os.path.exists(outdir):
                os.makedirs(outdir)

            for brainfilename in os.listdir(indir):
                if 'MNI152NLin6Asym_desc-brain_mask.nii.gz' in brainfilename or 'MNI152NLin6Asym_desc-preproc_T1w.nii.gz' in brainfilename:
                    shutil.copyfile(os.path.join(indir,brainfilename),os.path.join(outdir,brainfilename))
            os.system('fslmaths %s -mas %s %s'%(os.path.join(outdir,'sub-%s_space-MNI152NLin6Asym_desc-preproc_T1w.nii.gz'%biac),os.path.join(outdir,'sub-%s_space-MNI152NLin6Asym_desc-brain_mask.nii.gz'%biac),os.path.join(outdir,'sub-%s_masked_space-MNI152NLin6Asym_desc-preproc_T1w.nii.gz'%biac)))
                 
        

### MAIN SCRIPT ###

if __name__ == '__main__':
    main()
