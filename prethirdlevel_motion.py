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
    runs=['1']
    lookuptable = os.path.join(scriptdir,'Lookup','decide_AT_batch_lookup_singlesubj.txt')
    indirbase=os.path.join(homedir,project,'Analysis/BIDS/AmbiguityTolerance/fmriprep_EVRiskAmbig_2020/Level1/')
    outdirbase = os.path.join(bidsdir,'AmbiguityTolerance','fmriprep_EVRiskAmbig_2020')

    rmsDF = pd.DataFrame()
    relrmsDF = pd.DataFrame()
    lookupdf = pd.read_csv(lookuptable,sep='\t')
    for index,row in lookupdf.iterrows():
        if row['include'] == 1:
            biac = row['BIAC']
            date = row['date']
            group = row['group']
            print(str(biac))
            print(str(date))
            print(group)
            biac=str(biac)
            date=str(date)

            for run in runs:
              print(run)
              rundir = os.path.join(indirbase,'sub-%s'%(biac),'%s_AT%s.feat'%(biac,run),'mc')
              for brainfilename in os.listdir(rundir):
                  if 'prefiltered_func_data_mcf_abs_mean.rms' in brainfilename:
                      absrms = float(np.loadtxt(os.path.join(rundir,brainfilename)))
                      rmsDF = rmsDF.append({'subj':biac, 'group':group, 'run':run, 'AbsRMS':absrms}, ignore_index=True)
                  elif 'prefiltered_func_data_mcf_rel_mean.rms' in brainfilename:
                      relrms = float(np.loadtxt(os.path.join(rundir,brainfilename)))
                      relrmsDF = relrmsDF.append({'subj':biac, 'run':run, 'RelRMS':relrms}, ignore_index=True)
    rmsDF = pd.merge(rmsDF, relrmsDF, how='left', left_on=['subj','run'], right_on=['subj','run'])
    meanDF = rmsDF.groupby('subj').mean()
    finalDF = pd.merge(rmsDF,meanDF,how='left',left_on=['subj'], right_on=['subj'])
    finalDF.to_csv(os.path.join(outdirbase,'Motion.csv'))

        

### MAIN SCRIPT ###

if __name__ == '__main__':
    main()
