# This script will concatenate the phones for every utterance based on their position symbol [B / E / I], to create pronunciations for every utterance.
# Result format: uttid start stop phones
# Result saved in exp/alignment/final_ali_prons.txt

import os
import sys

expdir = sys.argv[1]

#if os.path.isfile(os.path.join(expdir,'final_ali_prons.txt')):
#	os.remove(os.path.join(expdir,'final_ali_prons.txt'))

with open(os.path.join(expdir,'final_ali.txt'),'r') as fid:
	with open(os.path.join(expdir,'final_ali_prons.txt'),'w') as pid:
		line = fid.readline()
		dur = 0.0
		pron = []
		while line:
			splitline = line.split(" ")
			utt = splitline[0]
			phone = splitline[4]
			if (phone == 'SIL\n') or (phone == 'SIL_S\n'):  # and also [SPN]?
				line = fid.readline()
			elif phone == '[SPN]_S\n':
				ending = float(splitline[2])+float(splitline[3])
				pid.write(utt+" "+splitline[2]+" "+str(ending)+" "+"SPN\n")
				line = fid.readline()
			elif phone.split("_")[1] == 'S\n':  # singleton phone in between words, e.g. y_S
				symb = phone.split("_")[0]
				ending = float(splitline[2])+float(splitline[3])
				pid.write(utt+" "+splitline[2]+" "+str(ending)+" "+symb+'\n')
				line = fid.readline()
			else:
				symb = phone.split("_")[0]
				pos = phone.split("_")[1]
				pron.append(symb)
				dur += float(splitline[3])

				if pos == 'B\n':
					start = float(splitline[2])
				
				if pos == 'E\n':
					end = start+dur
					pid.write(utt+" "+str(start)+" "+str(end)+" "+" ".join(pron)+"\n")
					dur = 0.0
					pron = []

				line = fid.readline()
