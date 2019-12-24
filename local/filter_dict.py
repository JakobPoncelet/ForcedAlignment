# This script filters out words which are not in our corpus.
# It requires a list of the words in the corpus: words.txt

import os
import sys

datadir = sys.argv[1]


ref = dict()  #keys=words,values=pronunciation
phones = dict()

with open(os.path.join(datadir,'lexicon.txt')) as f:
    for line in f:
        line = line.strip()
        columns = line.split("\t", 1)
        word = columns[0]
        pron = columns[1]
        try:
            ref[word].append(pron)
        except:
            ref[word] = list()
            ref[word].append(pron)

lex = open(os.path.join(datadir,'new_lexicon.txt'), "wb")

with open(os.path.join(datadir,'words.txt')) as f:
    for line in f:
        line = line.strip()
        if line in ref.keys():
            for pron in ref[line]:
                lex.write(line + " " + pron+"\n")
        else:
            print "Word not in lexicon: " + line
