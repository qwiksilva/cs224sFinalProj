"""This script gets the accuracies for a series of alignments"""

import os
import numpy as np
import sys

align_dir = "dev_pred"
gold_dir = "dev_target"

def GetAccuracies(dir1 = align_dir, dir2 = gold_dir):
    """Gets the accuracy comparison of two alignments"""
    
    #Initialization
    toterrors = 0.0
    totmaxerrors = 0
    totinsertions = 0
    totdeletions = 0
    totsubstitutions = 0
    deviations = list()
    pairdevs = list()
    
    #Get the list of common files:
    commonfiles = PairedFiles(dir1, dir2)

    if ".DS_Store" in commonfiles:
        commonfiles.remove(".DS_Store")
    
    print "###" + str(len(commonfiles)) + " common files"
    #Get the alignments for each file
    for f in commonfiles:
        # print str(f)
        #Parse the alignments
        alignment1 = ParseFile("%s/%s" % (dir1, f))
        alignment2 = ParseFile("%s/%s" % (dir2, f))
        #Compare them
        ((Nerrors, Maxerrors),(insertions, deletions, substitutions)), coincidences = EditDistance(alignment1, alignment2)
        #Update the error tracking
        toterrors += Nerrors
        totmaxerrors += Maxerrors
        totinsertions += insertions
        totdeletions += deletions
        totsubstitutions += substitutions
        newdeviations = list()
        pairdeviations = list()
        #Note - don't include cases where a single symbol was split into two in either alignment, where the endtime of the two resultant symbols is the same
        for i in range(len(coincidences)-1):
            if coincidences[i][0].endtime != coincidences[i+1][0].endtime and coincidences[i][1].endtime != coincidences[i+1][1].endtime:
                if coincidences[i][0] == coincidences[i+1][0] and coincidences[i][1] == coincidences[i+1][1]:
                    pairdeviations.append(abs(coincidences[i][0].endtime - coincidences[i][1].endtime))
                newdeviations.append(abs(coincidences[i][0].endtime - coincidences[i][1].endtime))
        newdeviations.append(abs(coincidences[-1][0].endtime - coincidences[-1][1].endtime))
        if coincidences[-1][0] == coincidences[-1][1]:
            pairdeviations.append(abs(coincidences[-1][0].endtime - coincidences[-1][1].endtime))
        deviations += newdeviations
        pairdevs += pairdeviations
        
        #Print the substitution errors
        #print ([(str(ph1), str(ph2)) for ph1, ph2 in coincidences if ph1 != ph2])
    
    #Print results
    print "Total phone errors: %s / %s  (%s I, %s D, %s S)" % (int(toterrors), totmaxerrors, totinsertions, totdeletions, totsubstitutions)
    print "Phone accuracy: %s %%" % round(100 - (100 * toterrors/totmaxerrors), 1)
    print "Mean aligned boundary deviation: %s ms" % round(1000 * np.mean(deviations), 1)
    print "Median aligned boundary deviation: %s ms" % round(1000 * np.median(deviations), 1)    
    print "%% aligned boundaries within 20ms: %s %%" % round((100 * len([d for d in deviations if d < 0.02]) / float(len(deviations))), 1)
    print "Mean aligned identical boundary deviation: %s ms" % round(1000 * np.mean(pairdevs), 1)
    print "Median aligned identical boundary deviation: %s ms" % round(1000 * np.median(pairdevs), 1)    
    print "%% aligned identical boundaries within 20ms: %s %%" % round((100 * len([d for d in pairdevs if d < 0.02]) / float(len(pairdevs))), 1)


def PairedFiles(dir1, dir2):
    Dev_Ex_files = ["2151-A-0009","2151-A-0029","2151-B-0010","2335-A-0005","2724-A-0002","2724-A-0042","2753-B-0017","3942-A-0002"]
    Test_Ex_files = ["3942-A-0027","3942-A-0054","3942-A-0055","3942-A-0069","3942-A-0082","3942-A-0085","3994-A-0074","3994-B-0034","3994-B-0053","3994-B-0061","3994-B-0067"]

    """Get the set of files with the same filename across two directories"""
    dir1files = set(os.listdir(dir1))
    dir2files = set(os.listdir(dir2))
    
    commonfiles = dir1files.intersection(dir2files)
    
    for elm in Dev_Ex_files:
        if elm in commonfiles:
            commonfiles.remove(elm)

    for elm in Test_Ex_files:
        if elm in commonfiles:
            commonfiles.remove(elm)

    return commonfiles

def ParseFile(f):
    """Parses a phone alignment file"""
    phoneslist = list()
    with open(f, "rb") as myFile:
        for line in myFile:
            endtime, phone = line.split()
            phoneslist.append(Phone(phone, endtime))
    return phoneslist
    

def EditDistance(a1, a2):
    """Finds the edit distance between two phone alignments,
    and also uses this to calculate the boundary errors"""
    #for all i and j, d[i,j] will hold the Levenshtein distance between
    #the first i characters of s and the first j characters of t;
    #note that d has (m+1)*(n+1) values
    
    d = np.zeros((len(a1) + 1, len(a2) + 1))
    
    #source prefixes can be transformed into empty string by
    #dropping all characters
    for i in range(len(a1)+1):
        d[i][0] = i
    
    #target prefixes can be reached from empty source prefix
    #by inserting every characters
    for j in range(len(a2)+1):
        d[0][j] = j
    
    for j in range(len(a2)):
        for i in range(len(a1)):
            if a1[i] == a2[j]:
                d[i+1][j+1] = d[i][j]   #no operation required
            else:
                d[i+1][j+1] = min([d[i][j+1] + 1, d[i+1][j] + 1, d[i][j] + 1])
    
    #Get the list of coincident symbols and the types of errors made
    insertions = 0
    deletions = 0
    substitutions = 0
    coincidences = list()
    i = len(a1)
    j = len(a2)
    while i > 0 and j > 0:
        m = min([d[i][j-1], d[i-1][j], d[i-1][j-1]])
        if d[i-1][j-1] == m:
            i -= 1
            j -= 1
            coincidences.append((a1[i], a2[j]))
            if a1[i] != a2[j]:
                #substitution error
                substitutions += 1
        elif d[i][j-1] == m:
            #deletion error
            j -= 1
            deletions += 1
        else:
            #insertion error
            i -= 1
            insertions += 1
    insertions += i
    deletions += j
    coincidences.reverse()
    
    return ((d[len(a1)][len(a2)], max([len(a1), len(a2)])), (insertions, deletions, substitutions)), coincidences


class Phone:
    
    def __init__(self, phone, endtime):
        self.phone = phone
        self.endtime = float(endtime)
        
    def __str__(self):
        return self.phone
        
    def __eq__(self, other):
        return self.phone == str(other) 
        
    def __ne__(self, other):
        return self.phone != str(other)   
        
                                    
# if __name__ == '__main__':
#     if len(sys.argv) == 3:
#         GetAccuracies(sys.argv[1],sys.argv[2])  
#     else:
#         GetAccuracies()  

test_pred_raw = "test_pred_raw"
test_DT_diff = "test_DT_diff"
test_pred_DT = "test_pred_DT"
test_gold = "test_target"

print "###### Without Decision Tree"

GetAccuracies("test_pred_raw", "test_target")  

print "###### With Decision Tree"

GetAccuracies("test_pred_DT", "test_target")  

print "###### With GBM"

GetAccuracies("test_pred_GBM", "test_target")  

print "###### With Mean"
GetAccuracies("test_pred_mean", "test_target")  

print "###### With Median"
GetAccuracies("test_pred_median", "test_target")  


