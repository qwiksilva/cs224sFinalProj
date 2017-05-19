"""
This script gets the pronunciations of words in a simplified format
and stores the result in txt files
"""

import os

#Directories
wrd_dir = "exp_txg_tst/wrd_simplified"
phn_dir = "exp_txg_tst/simplified"
out_dir = "exp_txg_tst/prons"

#Make out directory if required; otherwise empty it
if os.path.exists(out_dir):
    #Empty the folder
    for f in os.listdir(out_dir):
        os.remove("%s/%s" % (out_dir, f))
else:
    #Make the folder
    os.mkdir(out_dir)


def iterfile(f):
    """Helper function to open a file line by line, skipping header"""
    for line in f:
        fields = line.replace("\n","").split("\t")
        yield float(fields[0]), fields[-1].lower()

#Get list of filenames
files = os.listdir(wrd_dir)

#Iterate through filenames
for name in files:
    with open("%s/%s.txt" % (out_dir, name), "wb") as outFile:
        with open("%s/%s" % (wrd_dir, name), "rb") as wrdfile:
            with open("%s/%s" % (phn_dir, name), "rb") as phnfile:
                wrds = iterfile(wrdfile)
                phns = iterfile(phnfile)
                
                #Get first phone
                endphn, phnsymb = phns.next()
                
                #Iterate through words
                for endtime, word in wrds:
                    endphn = 0
                    pron = ""
                    if word == "h#":
                        try:
                            #Skip pauses
                            endphn, phnsymb = phns.next()
                        except:
                            break
                    else:
                        while endphn <= endtime:
                            if phnsymb != "h#":
                                pron += phnsymb + " "
                            try:
                                endphn, phnsymb = phns.next()
                            except:
                                break
                    #Now the pronunciation is complete. Trim extra spaces.
                    pron = pron.strip()
                    
                    #Add to pronunciation file
                    if word != "h#":
                        outFile.write("%s  %s\n" % (word, pron))