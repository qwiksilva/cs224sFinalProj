'''
take sim_phn and construct concatenate dictionary for FAVE-align

	sim_phn_dir = "phn_dev/simplified"
	dic_dir = "dic_dir"
	concate_dict = "concate_dict"
'''

import os
import sys
import shutil

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
	

def encode(s):
    s = s.replace("-", "")
    for i in range(10):
        s = s.replace(str(i), chr(65+i))
    return s


def construct(indirs, dict_file):
        if isinstance(indirs, str):
            indirs = [indirs]
            
	with open(dict_file, "wb") as dict_file:

            for indir in indirs:
                
		for filename in os.listdir(indir):
			print "filename = ",filename

			with open(os.path.join(indir,filename),"rb") as rfile:
				writeline = ""
				writeline += encode(filename) + "  "
				content = []
				for line in rfile:
					res = line.strip().split("\t")[1]
					# print res,
					content.append(toFaveDictFormat(res))
					# print toFaveDictFormat(res)
					
				writeline += " ".join(content)
				dict_file.write(writeline + "\n")
					# break
            
            dict_file.write("sp  sp")
			# break


if __name__ == "__main__":
	sim_phn_dirs = ["phn_dev/simplified", "phn_tst/simplified"]
	concate_dict = "dict_new"

	construct(sim_phn_dirs, concate_dict)


