"""This script gets the accuracies for a series of alignments"""

import os
import numpy as np
import sys

test_pred_raw = "test_pred_raw"

test_DT_diff = "test_DT_diff"
test_pred_DT = "test_pred_DT"

test_Mean_diff = "test_Mean_diff"
test_pred_mean = "test_pred_mean"

test_Median_diff = "test_Median_diff"
test_pred_median = "test_pred_median"

def GetTestPredDT(dir1 = test_pred_raw, dir2 = test_DT_diff, dir3 = test_pred_DT):
    commonfiles = PairedFiles(dir1, dir2)
    
    #Get the alignments for each file
    # for f in list(commonfiles)[0:1]:
    if ".DS_Store" in commonfiles:
        commonfiles.remove(".DS_Store")
        
    print len(commonfiles)
    
    for f in commonfiles:
    # for f in list(commonfiles)[0:1]:
        print str(f)
        
        f1 = open(dir1+"/"+f,'r')        
        raw_lines = f1.readlines()
        f1.close()

        f2 = open(dir2+"/"+f+".csv",'r')        
        diff_lines = f2.readlines()
        f2.close()

        # print test_list
        temp_file = open(dir3+ '/' + f,'w')
        for indx in range(0,len(diff_lines)):
            diff = float(diff_lines[indx])

            endtime, phone = raw_lines[indx].split()
            endtime = float(endtime) + diff

            temp_file.write(str(endtime)+"\t"+phone+"\n")

        temp_file.write(raw_lines[-1].strip()+"\n")
        temp_file.close()

def PairedFiles(dir1, dir2):
    Dev_Ex_files = ["2151-A-0009","2151-A-0029","2151-B-0010","2335-A-0005","2724-A-0002","2724-A-0042","2753-B-0017","3942-A-0002"]
    Test_Ex_files = ["3942-A-0027","3942-A-0054","3942-A-0055","3942-A-0069","3942-A-0082","3942-A-0085","3994-A-0074","3994-B-0034","3994-B-0053","3994-B-0061","3994-B-0067"]

    """Get the set of files with the same filename across two directories"""
    dir1files = set([elm.replace(".csv","") for elm in os.listdir(dir1)])
    dir2files = set([elm.replace(".csv","") for elm in os.listdir(dir2)])
    
    commonfiles = dir1files.intersection(dir2files)
    
    for elm in Dev_Ex_files:
        if elm in commonfiles:
            commonfiles.remove(elm)

    for elm in Test_Ex_files:
        if elm in commonfiles:
            commonfiles.remove(elm)

    return commonfiles

GetTestPredDT(test_pred_raw, "test_Mean_diff",   "test_pred_mean")
GetTestPredDT(test_pred_raw, "test_Median_diff", "test_pred_median")
GetTestPredDT(test_pred_raw, "test_DT_diff",     "test_pred_DT")
GetTestPredDT(test_pred_raw, "test_GBM_diff",    "test_pred_GBM")


