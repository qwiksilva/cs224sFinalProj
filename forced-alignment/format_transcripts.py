"""This script formats all of the transcripts in a provided folder into ELAN format."""

import os
import re

wrds_folder = "wrd_dev"
wrds_out_subfolder = "formatted"

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
                #Make h# into a breath
                if text == "h#":
                    text = "--"
                elif text.endswith("_#") or text.endswith("_!"):
                    text = text[:-2]
                elif "/" in text:
                    text = text.split("/")[-1]
                #Add word to list
                wordlist.append(text)
                #Get new line
                line = inFile.readline()
            
            #Now create output. Note endtime stores the wav end time
            outFile.write("Tier\tSpeaker\t0\t%s\t%s" % (endtime, " ".join(wordlist)))