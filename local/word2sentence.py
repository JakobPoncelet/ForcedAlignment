# This script combines the words into a sentence for every utterance, including the start and stop times.
# Result is stored in exp/alignment/final_ali_sentences.txt
# Result format: uttid sentence start(word1) stop(word1) start(word2) stop(word2) ....
# Exceptions: ggg means phone that was detected as spoken noise, XXXX means phones did not correspond to word in the new_lexicon

import os
import sys

expdir = sys.argv[1]

def file_len(fname):
    i = -1
    with open(fname) as f:
        for i, l in enumerate(f):
            pass
    return i + 1

num_lines = file_len(os.path.join(expdir,'final_ali_words.txt'))

linecount = 0
with open(os.path.join(expdir,'final_ali_words.txt'),'r') as fid:
	with open(os.path.join(expdir,'final_ali_sentences.txt'),'w') as pid:
		line = fid.readline()
		linecount += 1
		prev_utt = line.split(" ")[0]
		sentence = []
		start_stop_times = []
		while line:
			splitline = line.split(" ")
			utt = splitline[0]
			start = splitline[1]
			stop = splitline[2]
			word = (splitline[3])[:-1]  # remove the \n			

			if utt != prev_utt:
				pid.write(prev_utt+" "+" ".join(sentence)+" "+" ".join(start_stop_times)+'\n')
				sentence = []
				start_stop_times = []

			start_stop_times.append(start)
			start_stop_times.append(stop)
			sentence.append(word)

			prev_utt = utt

			if linecount == num_lines:
				pid.write(prev_utt+" "+" ".join(sentence)+" "+" ".join(start_stop_times)+'\n')

			line = fid.readline()
			linecount += 1

