"""This script simplifies the gold Switchboard word annotations
and snaps their alignment to that of the relevant phones"""

import os
import re

phns_folder = "phn_dev"
wrds_folder = "wrd_dev"
wrds_out_subfolder = "simplified"

wrdFiles = os.listdir(wrds_folder)
if wrds_out_subfolder in wrdFiles:
    #Remove the subfolder from the file listing
    wrdFiles.remove(wrds_out_subfolder)
    #Empty the subfolder
    for f in os.listdir("%s/%s" % (wrds_folder, wrds_out_subfolder)):
        os.remove("%s/%s/%s" % (wrds_folder, wrds_out_subfolder, f))
else:
    #Make the subfolder
    os.mkdir("%s/%s" % (wrds_folder, wrds_out_subfolder))
    
wrdFiles = [f for f in wrdFiles if f.endswith(".wrd")]

for filename in wrdFiles: 
    
    #Get list of timestamps in phns file
    phn_times = list()
    with open("%s/%s" % (phns_folder, filename.replace(".wrd",".phn")), "rb") as phnFile:
        #Read until the line which separates the comments from the alignments
        line = phnFile.readline()
        while not re.match(r"#", line):
            line = phnFile.readline()
                
        #The next line is the first alignment
        line = phnFile.readline()
        
        #Get endtimes
        while line != "":
            (endtime, ignore, phn) = line.split()
            phn_times.append(float(endtime))
            #New line
            line = phnFile.readline()
    
    #Go through word file and snap to phn times
    with open("%s/%s/%s" % (wrds_folder, wrds_out_subfolder, filename.replace(".wrd","")), "wb") as outFile:
    
        with open("%s/%s" % (wrds_folder, filename), "rb") as inFile:
            
            #Initialization
            
            #Get to the right place in the word file
            line = inFile.readline()
            while not re.match(r"#", line):
                line = inFile.readline()
                
            #Get the first word
            line = inFile.readline()
            
            phn_index = 0
            
            #Read each line
            while line != "":
                #Get word and word end
                (wordend, ignore, word) = line.split()
                wordend = float(wordend) 
                               
                #Skip phone pointer index ahead
                while wordend > phn_times[phn_index]:
                    if phn_index == len(phn_times) - 1:
                        break
                    else:
                        phn_index += 1
                
                #Now update wordend to nearest phn end
                if abs(wordend - phn_times[phn_index-1]) < abs(phn_times[phn_index] - wordend):
                    wordend = phn_times[phn_index-1]
                else:
                    wordend = phn_times[phn_index]
                    if phn_index < len(phn_times) - 1:
                        phn_index += 1
                
                #Write line to file
                outFile.write("%s\t%s\n" % (wordend, word.split("_")[0]))  
                
                #Advance line
                line = inFile.readline()           
                