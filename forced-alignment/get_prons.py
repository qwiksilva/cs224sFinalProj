"""
This script gets the pronunciation variants in the swbd dev set
"""

from collections import defaultdict
import os

def iterfile(f):
    """Helper function to open a file line by line, skipping header"""
    for line in f:
        fields = line.replace("\n","").split("\t")
        yield float(fields[0]), fields[-1].lower()

#Initialize pronunciation dictionary
prons = defaultdict(set)

#Get list of filenames
files = os.listdir("wrd_dev/simplified")

#Iterate through filenames
for name in files:
    with open("wrd_dev/simplified/%s" % name, "rb") as wrdfile:
        with open("phn_dev/simplified/%s" % name, "rb") as phnfile:
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
                
                #Add to pronunciation dict
                if word != "h#":
                    prons[word].add(pron)
                
#The pronouncing dictionary is complete.
#Write its contents to file.
with open("prons.csv", "wb") as outFile:
    outFile.write("Word,nProns,pron\n")
    for word in prons:
        for pron in prons[word]:
            outFile.write("%s,%s,%s\n" % (word, len(prons[word]), pron))