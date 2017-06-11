"""This script encodes all of the transcripts in a provided folder into ELAN format,
with transcript content given by the encoded filename."""

import os
import re

wrds_folder = "wrd_dev"
wrds_out_subfolder = "encoded"

def encode(s):
    s = s.replace("-", "")
    for i in range(10):
        s = s.replace(str(i), chr(65+i))
    return s

myFiles = os.listdir(wrds_folder)
if wrds_out_subfolder in myFiles:
    #Remove the subfolder from the file listing
    myFiles.remove(wrds_out_subfolder)
    #Empty the subfolder
    for f in os.listdir("%s/%s" % (wrds_folder, wrds_out_subfolder)):
        os.remove("%s/%s/%s" % (wrds_folder, wrds_out_subfolder, f))
else:
    #Make the subfolder
    os.mkdir("%s/%s" % (wrds_folder, wrds_out_subfolder))
    
myFiles.remove("formatted")

for filename in myFiles: 
    
    with open("%s/%s/%s.txt" % (wrds_folder, wrds_out_subfolder, filename.split('.')[0] ), "wb") as outFile:
    
        with open("%s/%s" % (wrds_folder, filename), "rb") as inFile:
            
            #Initialization
                
            #Get to the right place in the word file
            line = inFile.readline()
            while not re.match(r"#", line):
                line = inFile.readline()
                
            #The next line is the first alignment
            line = inFile.readline()
            
            #Iterate, collecting words in a list
            wordlist = list()
            while line != "":
                """Format is endtime ### text"""
                #Parse line
                (endtime, ignore, text) = line.split()
                #Get new line
                line = inFile.readline()
            
            #Now create output. Note endtime stores the wav end time
            outFile.write("Tier\tSpeaker\t0\t%s\t%s" % (endtime, encode(filename.split('.')[0])))