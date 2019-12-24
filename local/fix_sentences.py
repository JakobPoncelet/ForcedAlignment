# This script reads 1) final_ali_sentences.txt, which contains for every utterance the detected words and their corresponding start and stop times.
#		    2) the original/real transcriptions of the new data
# if the detected sentences have the same length, then bad words among the detected words (like oov's) could be swapped with the right words.

import os
import sys

datadir = sys.argv[1]
expdir = sys.argv[2]

reals = {}
dets = {}

with open(os.path.join(datadir,'text'),'r') as fid:
	with open(os.path.join(expdir,'final_ali_sentences.txt'),'r') as gid:
		line = gid.readline()
		textline = fid.readline()
		while line:
			num_det_words = len(line.split(" ")[1:])/3
			det_sentence = line.split(" ")[1:num_det_words+1]
			

			utt2 = line.split(" ")[0]

			dets[utt2] = 1
			
			#print 'a: ',real_sentence
			#print 'b: ',det_sentence
			line = gid.readline()

		while textline:
			real_sentence = textline.split(" ")[1:]	
			real_sentence[-1] = (real_sentence[-1])[:-1]  #remove the \n
			num_words = len(real_sentence)
			utt1 = textline.split(" ")[0]
			reals[utt1] = 1
			textline = fid.readline()

print 'Number of utterances: ', len(reals.keys())
print 'Number of aligned utterances: ', len(dets.keys())
print 'Bad utterances: '

with open(os.path.join(expdir,'final_ali_sentences.txt'),'a') as pid:
	for key in reals.keys():
		if key not in dets:
			print '    ', key
			pid.write(key+'\n')
