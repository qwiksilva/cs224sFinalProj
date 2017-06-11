"""This script gets the word-level pronunciation accuracies"""

import os

gold_prons_dir = "prons_tst"
algn_prons_dir = "exp_txg_tst/prons"

myFiles = os.listdir(gold_prons_dir)

exclusions = ["3942-A-0027", "3942-A-0054", "3942-A-0055", "3942-A-0069", "3942-A-0082", "3942-A-0085", "3994-A-0074", "3994-B-0034", "3994-B-0053", "3994-B-0061", "3994-B-0067"]

for e in exclusions:
    myFiles.remove("%s.txt" % e)

def iterfile(f):
    """Helper function to open a file line by line, skipping header"""
    for line in f:
        fields = line.replace("\n","").split("  ")
        yield fields

#Initialize
words = 0.0
correct = 0.0

for filename in myFiles:
    
    with open("%s/%s" % (gold_prons_dir, filename), "rb") as goldFile:
    
        with open("%s/%s" % (algn_prons_dir, filename), "rb") as algnFile:
            
            #Read each line of each file
            for goldline in goldFile:
                goldline = goldline.replace("\n","").split("  ")
                if goldline[0] != "?":
                    algnline = algnFile.readline().replace("\n","").split("  ")
                    if goldline[0].startswith("'"):
                        goldline[0] = goldline[0][1:]
                    if "-" in goldline[0]:
                        #concatenate algnline
                        tmp = algnFile.readline().replace("\n","").split("  ")
                        algnline[0] += "-%s" % tmp[0]
                        algnline[1] += " %s" % tmp[1]
                    
                    #Check they are the same word
                    if goldline[0] == algnline[0]:
                        words += 1
                        if goldline[1] == algnline[1]:
                            correct += 1
                    else:
                        print("Error on file %s: %s in gold matches %s in algn" % (filename, goldline[0], algnline[0]))
                    

print("Word accuracy: %s %%" % round(100 * correct/words, 1))
            