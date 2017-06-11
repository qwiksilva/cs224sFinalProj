"""This script simplifies the gold Switchboard phone annotations"""

import os
import re
import collections

phns_folder = "icsi_golden_phn"
phns_out_subfolder = "simplified"

myFiles = os.listdir(phns_folder)
# print myFiles
if phns_out_subfolder in myFiles:
    #Remove the subfolder from the file listing
    myFiles.remove(phns_out_subfolder)
    #Empty the subfolder
    for f in os.listdir("%s/%s" % (phns_folder, phns_out_subfolder)):
        os.remove("%s/%s/%s" % (phns_folder, phns_out_subfolder, f))
else:
    #Make the subfolder
    os.mkdir("%s/%s" % (phns_folder, phns_out_subfolder))

valid = []
with open("FILES-icsi", "rb") as validFiles:
    while True:
        line = validFiles.readline()
        # print line
        if not line:
            break
        valid.append(line.strip())

endtimes = collections.defaultdict(lambda: 0)

for filename in myFiles: 

    parts = filename.split('.')[0].split("-")
    if len(parts) != 3:
        continue
    prefix = "-".join(parts[:2])
    # print parts
    with open("%s/%s/%s" % (phns_folder, phns_out_subfolder, prefix ), "a+") as outFile:
    
        with open("%s/%s" % (phns_folder, filename), "rb") as inFile:
            
            if filename.split(".")[0] not in valid:
                # print filename.split(".")[0]
                continue

        # with open("%s/%s" % (phns_folder.replace('phn', 'wrd'), filename.replace('phn', 'wrd')), "rb") as wordFile:
        
            #Initialization
            
            #Get to the right place in the word file
            # wordline = wordFile.readline()
            # while not re.match(r"#", wordline):
            #     wordline = wordFile.readline()
                
            #Get the first word
            # wordline = wordFile.readline()
            # (wordend, ignore, word) = wordline.split()
                
            #For the phones file, read until the line which separates the comments from the alignments
            line = inFile.readline()
            while not re.match(r"#", line):
                line = inFile.readline()
            
            #The next line is the first alignment
            line = inFile.readline()
            
            alignments = list()
            #Iterate while there are lines to read
            while line != "":
                """Format is endtime ### text"""
                #Parse line
                (endtime, ignore, text) = line.split()[0:3]
                #Process text
                if "_" in text:
                    if '_vl' in text:
                        if text.startswith('b'):
                            text = 'p'
                        elif text.startswith('d'):
                            text = 't'
                        elif text.startswith('g'):
                            text = 'k'
                    if text.startswith('dx'):
                        if text.endswith('_t'):
                            text = 't'
                        else:
                            text = 'd'
                    if '_fr' in text:
                        if text.startswith('t'):
                            text = 'ch'
                        elif text.startswith('d'):
                            text = 'jh'
                    if '_vd' in text:
                        if text.startswith('p'):
                            text = 'b'
                        elif text.startswith('t'):
                            text = 'd'
                        elif text.startswith('k'):
                            text = 'g'
                    text = text.split('_')[0]
                if 'cl' in text:
                    text = text[0]
                elif text == 'ix':
                    text = 'ih'
                elif text == 'nx':
                    text = 'n'
                elif text == 'ux':
                    text = 'uh'
                elif text in ['q', '?']:
                    text = 'h#'
                elif text == 'em':
                    text = 'ax m'
                elif text == 'eng':
                    text = 'ax ng'
                elif text == 'axr':
                    text = 'ax r'
                elif text == 'el':
                    text = 'ax l'
                elif text == 'en':
                    text = 'ax n'
                #Write to list
                if prefix in endtimes:
                    endtime = float(endtime) + float(endtimes[prefix])

                print endtime
                    
                alignments += [[text.split()[i], endtime] for i in range(len(text.split()))]

                # if " " in text:
                #     alignments += [[text.split()[i], endtime] for i in range(len(text.split()))]
                # elif len(alignments) > 0 and text == alignments[-1][0] and float(wordend) > float(alignments[-1][1]) + 0.01:
                #     alignments[-1][1] = endtime
                # else:
                #     alignments.append([text, endtime])
                # #Update word endtime if required
                # if float(wordend) + 0.01 < float(alignments[-1][1]):
                #     wordline = wordFile.readline()
                #     if wordline != "":
                #         (wordend, ignore, word) = wordline.split()

                #Get new line
                line = inFile.readline()
            
            endtimes[prefix] = endtime
            print "newfile"

            # print len(alignments)
            #Write to file
            for text, endtime in alignments:
                outFile.write("%s\t%s\n" % (endtime, text))

print endtimes            
                