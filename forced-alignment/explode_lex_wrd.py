"""This script creates the dictionary files for each transcript, based on the pronunciations in prons_file"""

from collections import defaultdict

prons_file = "prons.csv"
dict_out = "dict_allprons"

cmupath = "FAVE-align/model/dict"

#Create CMU lookup dict
cmudict = defaultdict(set)
with open(cmupath, "rb") as cmuFile:
    for line in cmuFile:
        (word, pron) = line.replace("\n","").strip().split("  ")
        cmudict[word].add(pron)

def toFaveDictFormat(phone):
	vowels = ['AA', 'IY', 'AE', 'EH', 'AW', 'AH', 'UW', 'AO', 'IH', 'AY', 'EY', 'UH', 'OY', 'OW', 'ER']
	
	if phone == "h#":
		return "sp"

	if phone == "x":
		return "X"

	phone = phone.upper()

	# change ax to ah
	if phone.endswith("X"):
		phone = phone[:-1] + "H0"

	# add stress
	elif phone in vowels:
		phone += "1"

	return phone
	
#Add seen prons to cmudict
with open(prons_file, "rb") as pronsFile:
    #exclude first line
    exclflag = True
    for line in pronsFile:
        if exclflag:
            exclflag = False
        else:
            fields = line.replace(r"\n","").split(",")
            word = fields[0].upper()
            pron = " ".join([toFaveDictFormat(ph) for ph in fields[2].split()])
            if pron != "":
                cmudict[word].add(pron)

#Output new dict
with open(dict_out, "wb") as dictFile:
    for (word, prons) in sorted(cmudict.items()):
        if word != "sp":
            if word.startswith("'"):
                word = "\%s" % word
            for pron in sorted(prons):
                dictFile.write("%s  %s\n" % (word, pron))
    dictFile.write("sp  sp")