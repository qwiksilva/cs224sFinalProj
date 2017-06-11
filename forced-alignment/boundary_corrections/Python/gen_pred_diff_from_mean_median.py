import os
import numpy as np
import sys

def PairedFiles(dir1, dir2):
    """Get the set of files with the same filename across two directories"""
    # dir1files = set(os.listdir(dir1))
    # dir2files = set(os.listdir(dir2))
    dir1files = set([elem.replace(".csv","") for elem in os.listdir(dir1)])
    dir2files = set([elem.replace(".csv","") for elem in os.listdir(dir2)])
    return dir1files.intersection(dir2files)
    

####
def genDiff(test_input, test_Mean_diff, test_Median_diff):
    #### Build dictionary
    fname1 = "Mean_Diff.csv"
    mean_dict = {}
    f1 = open(fname1,"r")
    lines = f1.readlines()
    f1.close()
    for line in lines:
        temp_list = line.split() 
        if(len(temp_list) == 4):
            line = line.strip()
            line_num, left, right, mean_diff = temp_list
            mean_dict[(left, right)] = float(mean_diff)

    fname2 = "Median_Diff.csv"
    median_dict = {}
    f2 = open(fname2,"r")
    lines = f2.readlines()
    f2.close()
    for line in lines:
        temp_list = line.split() 
        if(len(temp_list) == 4):
            line = line.strip()
            line_num, left, right, median_diff = temp_list
            median_dict[(left, right)] = float(median_diff)
            
    ####
    # test_input = "test_input"
    # test_Mean_diff = "test_Mean_diff"
    # test_Median_diff = "test_Median_diff"

    commonfiles = os.listdir(test_input)
    if ".DS_Store" in commonfiles:
        commonfiles.remove(".DS_Store")
        
    for f in commonfiles:
    # for f in list(commonfiles)[0:1]:
        print str(f)
        
        f1 = open(test_input+"/"+f,'r')        
        raw_lines = f1.readlines()
        f1.close()

        # print test_list
        mean_diff_file = open(test_Mean_diff+ '/' + f,'w')
        median_diff_file = open(test_Median_diff+ '/' + f,'w')

        for line in raw_lines[1:]:
            line = line.strip()
            temp_list = line.split()

            left = temp_list[0]
            right = temp_list[1]
            if (str(left), str(right)) in mean_dict:
                mean_diff = mean_dict[(left, right)]
            else:
                mean_diff = 0

            mean_diff_file.write(str(mean_diff)+"\n")

            if (left, right) in median_dict:
                mean_diff = median_dict[(left, right)]
            else:
                mean_diff = 0

            median_diff_file.write(str(mean_diff)+"\n")

        mean_diff_file.close()
        median_diff_file.close()
#####
test_input = "test_input"
test_Mean_diff = "test_Mean_diff"
test_Median_diff = "test_Median_diff"
genDiff(test_input, test_Mean_diff, test_Median_diff)

train_input = "train_input"
train_Mean_diff = "train_Mean_diff"
train_Median_diff = "train_Median_diff"
genDiff(train_input, train_Mean_diff, train_Median_diff)
