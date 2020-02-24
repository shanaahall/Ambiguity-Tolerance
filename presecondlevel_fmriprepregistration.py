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
import glob

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
    runs=['1','2']
    lookuptable = os.path.join(scriptdir,'Lookup','decide_AT_batch_lookup_singlesubj.txt')
    indirbase=os.path.join(homedir,project,'Analysis','BIDS','AmbiguityTolerance','fmriprep_EVRiskAmbig_2020','Level1_wResp','')
    #outdirbase = os.path.join(bidsdir,'AmbiguityTolerance','Timingfsf','Timing','')
    fsldir = '/usr/local/packages/fsl-5.0.9'

    lookupdf = pd.read_csv(lookuptable,sep='\t')
    for index,row in lookupdf.iterrows():
        if row['include'] == 1:
            biac = row['BIAC']
            biac=str(biac)
            for run in runs:
                indir = os.path.join(indirbase,'sub-%s'%biac,'%s_AT%s.feat'%(biac,run))

                if os.path.exists(os.path.join(indir,'reg_standard')):
                    shutil.rmtree(os.path.join(indir,'reg_standard'))
                fileList = glob.glob(os.path.join(indir,'reg','*.mat'))
                for filePath in fileList:
                    os.remove(filePath)
                shutil.copy(os.path.join(fsldir,'etc','flirtsch','ident.mat'),os.path.join(indir,'reg','example_func2standard.mat'))
                shutil.copy(os.path.join(indir,'mean_func.nii.gz'),os.path.join(indir,'reg','standard.nii.gz'))
                 
        

### MAIN SCRIPT ###

if __name__ == '__main__':
    main()
