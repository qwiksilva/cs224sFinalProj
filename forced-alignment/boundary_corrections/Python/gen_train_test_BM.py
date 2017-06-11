"""This script gets the accuracies for a series of alignments"""

import os
import numpy as np
import sys

align_dir = "dev_pred"
gold_dir = "dev_target"
# align_dir = "test1"
# gold_dir = "test2"

align_test = "test_pred_raw"
gold_test = "test_target"

train_input = "train_input"
test_input = "test_input"

def GetTest(dir1 = align_test, dir2 = gold_test):
    commonfiles = PairedFiles(dir1, dir2)
    
    #Get the alignments for each file
    # for f in list(commonfiles)[0:1]:
    if ".DS_Store" in commonfiles:
        commonfiles.remove(".DS_Store")
        
    print len(commonfiles)
    for f in commonfiles:
        print str(f)
        #Parse the alignments
        alignment1 = ParseFile("%s/%s" % (dir1, f))
     
        test_list = []
        for indx in range(0,len(alignment1)-1):
            test_list.append( (alignment1[indx].phone, alignment1[indx+1].phone) )

        # print test_list
        temp_file = open(test_input+ '/' + f + '.csv','w')
        temp_file.write("Left"+"\t"+"Right"+"\n")
        for elem in test_list:
            Left = elem[0]
            Right = elem[1]
            temp_file.write(Left+"\t"+Right+"\n")

def GetTrain(dir1 = align_dir, dir2 = gold_dir):
    commonfiles = PairedFiles(dir1, dir2)
    
    #Get the alignments for each file
    # for f in list(commonfiles)[0:1]:
    if ".DS_Store" in commonfiles:
        commonfiles.remove(".DS_Store")

    print len(commonfiles)
    for f in commonfiles:
        print str(f)
        #Parse the alignments
        alignment1 = ParseFile("%s/%s" % (dir1, f))
        alignment2 = ParseFile("%s/%s" % (dir2, f))
        
        ###### Old without order
        # pair_list_align = []
        # for indx in range(0,len(alignment1)-1):
        #     pair_list_align.append( (alignment1[indx].phone, alignment1[indx+1].phone) )


        # pair_list_gold = []
        # for indx in range(0,len(alignment2)-1):
        #     pair_list_gold.append( (alignment2[indx].phone, alignment2[indx+1].phone) )

        # # print pair_list_gold

        # #Compare them
        # ((Nerrors, Maxerrors),(insertions, deletions, substitutions)), coincidences = EditDistance(alignment1, alignment2)

        # # print "####"
        # train_list = []
        # # for indx in range(1,len(coincidences)-2):
        # for indx in range(0,len(coincidences)-1):
        #     if (coincidences[indx][0].phone, coincidences[indx+1][0].phone) in pair_list_gold:
        #         if (coincidences[indx][1].phone, coincidences[indx+1][1].phone) in pair_list_gold:
        #             if (coincidences[indx][0].phone == coincidences[indx][1].phone) and (coincidences[indx+1][0].phone == coincidences[indx+1][1].phone):
        #                 train_list.append( (coincidences[indx][1].phone, coincidences[indx+1][1].phone, float(coincidences[indx][1].endtime- coincidences[indx][0].endtime) ) )

        ####### New with order constraints
        pair_list_align = []
        for indx in range(0,len(alignment1)-1):
            pair_list_align.append( (alignment1[indx], alignment1[indx+1]) )


        pair_list_gold = []
        for indx in range(0,len(alignment2)-1):
            pair_list_gold.append( (alignment2[indx], alignment2[indx+1]) )

        # print pair_list_gold

        #Compare them
        ((Nerrors, Maxerrors),(insertions, deletions, substitutions)), coincidences = EditDistance(alignment1, alignment2)

        # print "####"
        train_list = []
        # for indx in range(1,len(coincidences)-2):
        cur_pair_list_align_indx = 0
        cur_pair_list_gold_indx = 0
        for indx in range(0,len(coincidences)-1):
            if (coincidences[indx][0], coincidences[indx+1][0]) in pair_list_align:
                cur_pair_list_align_indx = pair_list_align.index((coincidences[indx][0], coincidences[indx+1][0]))

                if (coincidences[indx][1], coincidences[indx+1][1]) in pair_list_gold:
                    cur_pair_list_gold_indx = pair_list_gold.index((coincidences[indx][1], coincidences[indx+1][1]))

                    if (coincidences[indx][0] == coincidences[indx][1]) and (coincidences[indx+1][0] == coincidences[indx+1][1]):
                        # if cur_pair_list_align_indx >= pair_list_align_indx and  cur_pair_list_gold_indx >= pair_list_gold_indx:
                        if (pair_list_align[cur_pair_list_align_indx][0].endtime == coincidences[indx][0].endtime) and (pair_list_gold[cur_pair_list_gold_indx][0].endtime == coincidences[indx][1].endtime):
                            pair_list_align = pair_list_align[cur_pair_list_align_indx:]
                            pair_list_gold  = pair_list_gold[cur_pair_list_gold_indx:] 
                            train_list.append( (coincidences[indx][1].phone, coincidences[indx+1][1].phone, float(coincidences[indx][1].endtime- coincidences[indx][0].endtime) ) )

        # print train_list
        temp_file = open(train_input+ '/' + f + '.csv','w')
        temp_file.write("Left"+"\t"+"Right"+"\t"+"Diff"+"\n")
        for elem in train_list:
            Left = elem[0]
            Right = elem[1]
            Diff = elem[2]
            temp_file.write(Left+"\t"+Right+"\t"+ str(Diff)+"\n")

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

# if __name__ == '__main__':
#     if len(sys.argv) == 3:
#         GetTrain(sys.argv[1],sys.argv[2])  
#     else:
#         GetTrain()  

GetTrain()  
GetTest()  

