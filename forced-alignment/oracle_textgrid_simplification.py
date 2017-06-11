"""This script simplifies the textgrids output by FAVE-align into a format
comparable to that of the gold (hand-aligned) Switchboard files for the oracle
alignments"""

import os
import re

textgrids_folder = "orc_txg_dev"
textgrids_out_subfolder = "simplified"
gold_folder = "phn_dev/simplified"

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

for filename in myFiles:
    
    #Get the gold phone sequence
    goldseq = list()
    with open("%s/%s" % (gold_folder, filename.split('.')[0]), "rb") as goldFile:
        for line in goldFile:
            ph = line.replace("\n","").split("\t")[-1]
            if ph != "":
                goldseq.append(ph)
    
    errorflag = False
    
    with open("%s/%s/%s" % (textgrids_folder, textgrids_out_subfolder, filename.split('.')[0]), "wb") as outFile:
    
        with open("%s/%s" % (textgrids_folder, filename), "rb") as inFile:
            
            #Read until the line which introduces the phone tier
            line = inFile.readline()
            while not re.search(r"name\s+=.*phone", line, re.I):
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
                out = list()
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
                    if text == 'ah0':
                        text = 'ax'
                    elif re.search(r"\d", text):
                        text = text[:-1]
                    elif text in ['br', 'cg', 'lg', 'ls', 'ns', 'sil', 'sp']:
                        text = 'h#'        
                    #Append to output list
                    out.append([endtime, text])
            
                ##Check that the phone sequence is correct
                ##The aligner won't insert sp mid-sentence where it detects sufficient evidence for other phones;
                ##in these cases, we insert a single sp frame
                #i = 0
                #while i < max(len(out), len(goldseq)):
                #    if out[i][1] == "h#" and (i >= len(goldseq) or out[i][1] != goldseq[i]):
                #        #Extra h# inserted
                #        if i > 0:
                #            out[i-1][0] = out[i][0]
                #        del out[i]
                #    elif goldseq[i] == "h#" and (i >= len(out) or out[i][1] != goldseq[i]):
                #        #h# deleted
                #        if i > 0 and i < len(out):
                #            out[i-1][0] = str(float(out[i-1][0]) - 0.005)
                #            out = out[:i] + [[str(float(out[i-1][0]) + 0.01), "h#"]] + out[i:]
                #        elif i == 0:
                #            out[0][0] = str(float(out[0][0]) + 0.01)
                #            out = [[0.01, "h#"]] + out
                #        elif i == len(out):
                #            out = out + [[out[-1][0], "h#"]]
                #            out[-2][0] = str(float(out[-2][0]) - 0.01)
                #    elif out[i][1] == goldseq[i]:
                #        i += 1   
                
                #Check the number of sps at the start and end is correct
                goldsps = [0, 0]
                i = 0
                while goldseq[i] == "h#":
                    goldsps[0] += 1
                    i += 1
                i = -1
                while goldseq[i] == "h#":
                    goldsps[1] += 1
                    i -= 1
                outsps = [0, 0]
                i = 0
                while out[i][1] == "h#":
                    outsps[0] += 1
                    i += 1
                i = -1
                while out[i][1] == "h#":
                    outsps[1] += 1
                    i -= 1                                 
                #Correct beginning
                if goldsps[0] < outsps[0]:
                    for i in range(outsps[0] - goldsps[0]):
                        del out[0]
                #Correct ending
                if 0 < goldsps[1] < outsps[1]:
                    for i in range(-1-(outsps[1]-goldsps[1]),-1):
                        del out[i]
                
                #Now write to file
                for (endtime, text) in out:
                    outFile.write("%s\t%s\n" % (endtime, text))