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
    #indirbase=os.path.join(homedir,project,'Analysis/Behavioral/combined_AT_files/AT_Timing_2016_0805','')
    indirbase=os.path.join(homedir,project,'Notes/AT_Timing_Responses_2','')
    outdirbase = os.path.join(bidsdir,'AmbiguityTolerance','Timing','')

    lookupdf = pd.read_csv(lookuptable,sep='\t')
    for index,row in lookupdf.iterrows():
        if row['include'] == 1:
            decideid = row['DECIDEID']
            biac = row['BIAC']
            date = row['date']
            group = row['group']
            decideid=str(decideid)
            biac=str(biac)
            date=str(date)

            for timingfilename in os.listdir(indirbase):
                if decideid in timingfilename:
                    fileparts = timingfilename.split('_')
                    newfilename = fileparts[0] + '_' + biac + '_' + fileparts[2] + '_' + fileparts[3] + '_' + fileparts[4]
                    #newfilename = fileparts[0] + '_' + biac + '_' + fileparts[2] + '_' + fileparts[3]
                    shutil.copyfile(os.path.join(indirbase,timingfilename),os.path.join(outdirbase,newfilename)) 
                 
        

### MAIN SCRIPT ###

if __name__ == '__main__':
    main()
