"""This script simplifies the textgrids output by FAVE-align into a format
comparable to that of the gold (hand-aligned) Switchboard files,
yielding the word-level alignments"""

import os
import re

textgrids_folder = "exp_txg_tst"
textgrids_out_subfolder = "wrd_simplified"

myFiles = os.listdir(textgrids_folder)
if textgrids_out_subfolder in myFiles:
    #Remove the subfolder from the file listing
    myFiles.remove(textgrids_out_subfolder)
    #Empty the subfolder
    for f in os.listdir("%s/%s" % (textgrids_folder, textgrids_out_subfolder)):
        os.remove("%s/%s/%s" % (textgrids_folder, textgrids_out_subfolder, f))    
else:
    #Make the subfolder
    os.mkdir("%s/%s" % (textgrids_folder, textgrids_out_subfolder))

myFiles.remove("simplified")

for filename in myFiles:
    
    errorflag = False
    
    with open("%s/%s/%s" % (textgrids_folder, textgrids_out_subfolder, filename.split('.')[0]), "wb") as outFile:
    
        with open("%s/%s" % (textgrids_folder, filename), "rb") as inFile:
            
            #Read until the line which introduces the phone tier
            line = inFile.readline()
            while not re.search(r"name\s+=.*word", line, re.I):
                line = inFile.readline()
                if line == "":
                    print "Error with %s; skipping" % filename
                    errorflag = True
                    break
            
            if not errorflag:
            
                #3 lines from here is the is the number of intervals
                for i in range(3):
                    line = inFile.readline()
                    
                #Extract the number of intervals
                intervals = int(re.search(r"size\s+=\s+(\d+)", line).group(1))
                
                #Iterate through this many intervals
                for i in range(intervals):
                    """This is a block of 4 lines:
                    (1) interval header
                    (2) starttime
                    (3) endtime
                    (4) text = "___"
                    We want endtime and text"""
                    #Skip unimportant lines
                    for i in range(3):
                        line = inFile.readline()
                    #Get endtime
                    endtime = re.search(r"xmax\s+=\s+(\d+\.\d+)", line).group(1)
                    #Get text
                    line = inFile.readline()
                    text = re.search(r"text\s+=\s+\"([^\"]+)\"", line).group(1).lower()
                    #Process text
                    if text in ['br', 'cg', 'lg', 'ls', 'ns', 'sil', 'sp']:
                        text = 'h#'        
                    #Write to file
                    outFile.write("%s\t%s\n" % (endtime, text))
            