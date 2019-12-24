# This script changes the phone id's to phones in a given merged_alignment.txt file and a phones.txt file.
# It will also split into all utterances separately if the # XXXX lines are uncommented.

# Format: uttid channel start duration phone   (channel=1 because mono audio, phone=position specific phone, e.g. r_B Beginning)



import os
import sys
import shutil

langdir = sys.argv[1]
expdir = sys.argv[2]

if os.path.exists(os.path.join(expdir,'alignments_per_utterance')):
	shutil.rmtree(os.path.join(expdir,'alignments_per_utterance'))

os.mkdir(os.path.join(expdir,'alignments_per_utterance'))  # XXXX

phonedict = {}

with open(os.path.join(langdir,'phones.txt'),'r') as fid:
	line = fid.readline()
	while line:
		phone = line.split(" ")[0]
		phoneid = line.split(" ")[1]
		phonedict[phoneid] = phone
		line = fid.readline()

with open(os.path.join(expdir,'final_ali.txt'),'w+') as gid:
	with open(os.path.join(expdir,'merged_alignment.txt'),'r') as pid:
		line = pid.readline()
		while line:
			phoneid = line.split(" ")[4]
			phone = phonedict[phoneid]
			newline = line.split(" ")[0:4]
			newline.append(phone+'\n')
			gid.write(" ".join(newline))
			utt = line.split(" ")[0] # XXXX
			with open(os.path.join(expdir,'alignments_per_utterance',utt+'.txt'),'a') as tid: # XXXX
				tid.write(" ".join(newline)) # XXXX
			line = pid.readline()
