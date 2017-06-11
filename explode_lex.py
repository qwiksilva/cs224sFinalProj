"""This script creates an enhanced overall lexicon"""

import re
import math
from collections import defaultdict
import os

wrd_folder = "swbd_dict/lexicon.txt"
dict_folder = "swbd_enriched_lex/lexicon_tsimple.txt"

cmupath = "FAVE-align/model/dict"

#Create CMU lookup dict
cmudict = defaultdict(set)
with open(cmupath, "rb") as cmuFile:
    for line in cmuFile:
        (word, pron) = line.replace("\n","").strip().split("  ")
        cmudict[word].add(pron)

def explode(word, prons):
    for rule in rules:
        prons = apply(rule, prons, word=word)
    if word in functionwords:
        prons = apply(unstress_V, prons)
        prons = apply(vowel_del, prons)
    if "" in prons:
        prons.remove("")
    return prons
        
def apply(rule, prons, word=""):
    for pron in prons:
        prons = prons.union(rule.applyTo(pron, word=word))
    return prons
    

class Rule:
    
    def __init__(self, target, result, Lenv="", Renv=""):
        self.target = target
        self.result = result
        if "#" in Lenv:
            self.Lenv = Lenv + " "
        else:
            self.Lenv = Lenv + r"\b"
        if "#" in Renv:
            self.Renv = " " + Renv
        else:
            self.Renv = Renv = r"\b" + Renv
        
    def applyTo(self, pron, word=""):
        pron = "# %s #" % pron
        constants = re.split("%s%s%s" % (self.Lenv, self.target, self.Renv), pron)
        if len(constants) == 1:
            return set()
        matches = re.findall("%s%s%s" % (self.Lenv, self.target, self.Renv), pron)
        for i in range(len(matches)):
            matches[i] = list(re.search("(%s)(%s)(%s)" % (self.Lenv, self.target, self.Renv), matches[i]).groups())
        newProns = set()
        Nmatches = len(matches)
        for n in range(2**Nmatches):
            newPron = ""
            indices = int2indices(n)
            for i in range(len(constants)-1):
                newPron += constants[i]
                if i in indices:
                    newPron += "".join([matches[i][0], self.result, matches[i][2]])
                else:
                    newPron += "".join(matches[i])
            newPron += constants[-1]
            newPron = newPron[2:-2]
            newPron = re.sub(" {2,}", " ", newPron)
            newPron = newPron.strip()
            newProns.add(newPron)
        return newProns
        

def int2indices(n):
    indices = list()
    while n > 0:
        i = int(math.log(n, 2))
        indices.append(i)
        n -= 2**i
    return indices
  
#Classes of sounds
vowels = ['AA', 'IY', 'AE', 'EH', 'AW', 'AH', 'UW', 'AO', 'IH', 'AY', 'EY', 'UH', 'OY', 'OW', 'ER']
voiced = vowels + ["B", "M", "N", "NG", "D", "DH", "JH", "Z", "V", "R", "L", "Y", "W", "ZH", "G", "#"]
voiceless = ["P", "T", "TH", "SH", "CH", "S", "F", "K", "#"]
consonants = ["P", "B", "F", "V", "M", "N", "T", "D", "S", "Z", "TH", "DH", "SH", "ZH", "CH", "JH", "K", "G", "NG"]
        
#Make rules
destress_iy = Rule("(?:IY|IY0)", "IH")
destress_uw = Rule("(?:UW|UW0)", "UH")
stress_ih = Rule("IH1", "IY1")
schwa = Rule("\S+0", "AH0")
td_del = Rule("[TD]", "", Renv="#")
l_voc = Rule("L", "UH0", Renv="(?:#|\S+0)")
ay_monopth = Rule("AY\d", "AA1")
ao_monopth = Rule("AO\d", "UH1")
h_del = Rule("HH", "", Lenv="#")
r_vocrot = Rule("R", "ER0", Renv="#")
r_voc = Rule("R", "AH0", Renv="#")
t_voice = Rule("T", "D", Renv="(?:%s)" % "|".join(voiced))
p_voice = Rule("P", "B", Renv="(?:%s)" % "|".join(voiced))
k_voice = Rule("K", "G", Renv="(?:%s)" % "|".join(voiced))
d_devoice = Rule("D", "T", Renv="(?:%s)" % "|".join(voiceless))
b_devoice = Rule("B", "P", Renv="(?:%s)" % "|".join(voiceless))
g_devoice = Rule("G", "K", Renv="(?:%s)" % "|".join(voiceless))
t_fric = Rule("T", "CH", Renv="[RY]")
d_fric = Rule("D", "JH", Renv="[RY]")
nasal_m = Rule("(?:N|M|NG)", "M", Renv="[PBFVM#]")
nasal_n = Rule("(?:N|M|NG)", "N", Renv="(?:TH|DH|SH|ZH|CH|JH|[TDSZN#])")
nasal_ng = Rule("(?:N|M|NG)", "NG", Renv="(?:NG|[KG#])")
dh_unfric = Rule("DH", "D")
th_unfric = Rule("TH", "T")
t_simpl = Rule("T", "", Renv=" (?:S|CH|SH)")
d_simpl = Rule("D", "", Renv="(?:Z|JH|ZH)")
unstr_syll_del = Rule("[^1]+0", "", Lenv="#", Renv=".+1")
g_drop = Rule("(?:IH|IH0) NG", "IH N")

#Function word extreme reduction rules
segment_del = Rule(r"\b\S+\b", " ")
unstress_V = Rule(r"\S+\d", "AH0")
vowel_del = Rule(r"(?:%s)" % "|".join(vowels), "")

#Ordered rules
rules = [destress_iy, destress_uw, g_drop, td_del, h_del]
#Function words
functionwords = ["THE", "AT", "TO", "IN", "ON", "AN", "THAT", "THIS", "THAT'S", "OF", "CAN", "CAN'T", "HE", "HIM", "HIS", "SHE", "HER", "HERS", "THEY", "THEM", "THEIR", "THEIRS", "WE", "OUR", "OURS", "US", "YOU", "YOUR", "IS", "ARE", "AREN'T", "AND", "ISN'T", "BE", "IF", "THEN", "WELL", "YES", "NOT"]

with open(wrd_folder, "rb") as inFile:
    with open(dict_folder, "wb") as outFile:
        words = set()
        fileProns = dict()
        for line in inFile:
            split = line.replace("\n","").split()
            word = split[0].upper()
            pron = " ".join(split[1:]).upper()
            if word not in fileProns:
                fileProns[word] = cmudict[word]

            fileProns[word].add(pron)

        for word in fileProns:
            fileProns[word] = explode(word, fileProns[word])
            
        #Write the pronunciation dicts to file
        for (word, prons) in sorted(fileProns.items()):
            newPronSet = set()
            word = word.lower()
            for pron in sorted(prons):
                split = pron.lower().split()
                for i, phn in enumerate(split):
                    if phn[-1].isdigit():
                        split[i] = phn[:-1]
                pron1 = " ".join(split)
                newPronSet.add(pron1)

            for pron in sorted(newPronSet):

                pron = pron.lower()
                outFile.write("%s %s\n" % (word, pron))




