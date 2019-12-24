# This script looks up the pronunciations of in the new_lexicon created with all words from the new dataset (that exist in the old one).
# The result is saved in exp/alignment/final_ali_words.txt
# Result format: uttid start stop word
# exceptions: - if one of the phones is detected as spoken noise (and the word is thus not recognized), then word = ggg
# 	      - if a collection of phones does not correspond to a word in the vocab of the new database, then word = XXXX

# 20/12 // deleted all XXXX from the data for now, because word boundaries were messed up

import os
import sys

datadir = sys.argv[1]
expdir = sys.argv[2]

lex = {}

with open(os.path.join(datadir,'new_lexicon.txt'),'r') as gid:
	line = gid.readline()
	while line:
		splitline = line.split(" ")
		word = splitline[0]
		pron = splitline[1:]
		lex[word] = pron
		line = gid.readline()

def get_key(val, mydict): 
    for key, value in mydict.items(): 
         if val == value: 
             return key 
  
    return None

with open(os.path.join(expdir,'final_ali_prons.txt'),'r') as fid:
	with open(os.path.join(expdir,'final_ali_words.txt'),'w') as pid:
		line = fid.readline()
		while line:
			splitline = line.split(" ")
			pron = splitline[3:]
			word = get_key(pron, lex)

			if ('SPN\n' in pron) or ('SPN' in pron):
				word = "ggg"
			if word == None:
				word = "XXX"

			newline = splitline[0:3]
			newline.append(word+'\n')
			pid.write(" ".join(newline))
			line = fid.readline()




