#!/bin/bash

# ALIGNMENT SCRIPT FOR GRABO WITH EXISTING ACOUSTIC MODEL

# Before you can run this script, change path.sh to your setting!!

# Usage script with singularity kaldi install:
# 1) cd /users/spraak/spch/prog/spch/kaldi
# 2) singularity shell --nv singularity.img
# 3) go to the directory where this file is and do "bash run.sh"
# (after copying or linking <modeldir> and <langdir> from the acoustic model directory)

# Note: you could try adding pronunciations of oov words from your new database 
# (that are not in the data of the model) to the model's language

# Inspired by scripts from E. Chodroff, read this page to understand the steps:
# https://www.eleanorchodroff.com/tutorial/kaldi/forced-alignment.html

## SETUP ####################################################################
# kaldi root
kaldiroot=/users/spraak/spch/prog/spch/kaldi
# location of database
database=/users/spraak/spchdata/grabo
# all speakers you want to prepare in GRABO  (e.g. leave out the English speaker pp5)
valid_spk="pp2 pp3 pp4 pp6 pp7 pp8 pp9 pp10 pp11 pp12"
# target data directory
datadir=data/alignment
# where to store the alignment experiment files
expdir=exp/alignment
# where to store the features
mfccdir=exp/mfcc
# acoustic model used for the aligment (copy this from acoustic model)
#modeldir=/esat/spchdisk/scratch/jponcele/KALDI23/egs/CGN/exp/train_cleaned/tri4
modeldir=/esat/spchdisk/scratch/jponcele/KALDI23/egs/CGN/exp2/chain_cleaned/tree_bi1i
# data language directory (copy this from acoustic model)
langdir=/esat/spchdisk/scratch/jponcele/KALDI23/egs/CGN/data/lang_s
# set the stage to skip certain parts
stage=0
############################################################################

echo "#### LOADING PATHS ###############################"
. ./cmd.sh
. ./path.sh
[ ! -e steps ] && ln -s $kaldiroot/egs/wsj/s5/steps steps
[ ! -e utils ] && ln -s $kaldiroot/egs/wsj/s5/utils utils
. utils/parse_options.sh

if [ $stage -le 0 ]; then
  echo "#### PREPARING THE NEW DATABASE ##################"
  . local/grabo_dataprep.sh $database $datadir $valid_spk
fi

if [ $stage -le 1 ]; then
  echo "#### EXTRACTING MFCC FEATURES ####################"
  for x in $datadir; do
      utils/fix_data_dir.sh $x
      steps/make_mfcc.sh --cmd "$train_cmd" --nj 16 $x $mfccdir/make_mfcc/$x $mfccdir
      steps/compute_cmvn_stats.sh $x $mfccdir/make_mfcc/$x $mfccdir
      utils/fix_data_dir.sh $x
  done
fi

if [ $stage -le 2 ]; then
  echo "#### COMPUTING THE ALIGNMENTS ####################"
  # when many alignments fail, make beam and retry-beam larger and run again
  steps/align_si.sh --cmd "$train_cmd" --beam 10 --retry-beam 40 $datadir $langdir $modeldir $expdir || exit 1;
fi

if [ $stage -le 3 ]; then
  echo "#### CREATING CTM/TXT FILES WITH ALIGNMENTS ######"
  for i in $expdir/ali.*.gz; do
    ali-to-phones --ctm-output $modeldir/final.mdl ark:"gunzip -c $i|" -> ${i%.gz}.ctm;
  done

  cat $expdir/*.ctm > $expdir/merged_alignment.txt
  
  echo "Converting phone id's to real phones and create txt files for every utterance separately if not commented out (takes a minute) ..."
  python local/id2phone.py $langdir $expdir

  echo "Converting phones to pronunciations..."
  # NOTE: for now, SIL gets filtered out, SPN and singleton phones are kept
  python local/phone2pron.py $expdir

  echo "Converting pronunciations to words..."
  python local/pron2word.py $datadir $expdir

  echo "Converting words to sentences..."
  python local/word2sentence.py $expdir

  echo "Check if the detected transcripts correspond to the actual ones and print bad recordings/alignments"
  python local/fix_sentences.py $datadir $expdir
fi

sort $datadir/text > $datadir/TEXT
sort $expdir/final_ali_sentences.txt > $expdir/ALIGNMENTS.txt

echo "ALL DONE --- Final results are in $expdir/ALIGNMENTS.txt (words) and $expdir/alignments_per_utterance (phones)"
echo "(now run run_praat.sh to get praat textgrids for visualization)"
