#!/bin/bash

# This script should be run after run.sh. It will create praat textgrids from the computed alignments.
# However, this script contains no kaldi functions and can thus be run outside of the singularity, which is why this is a separate script. You also have to edit the directory locations in the setup inside the .praat scripts yourself, besides the setup in this script.
# Note: requires a machine with praat installed, like fasso.
# To view the results: 
# 1) type 'praat' in terminal  
# 2) in object window (behind the picture): open -> read from file -> choose a textgrid
# 3) "" 				    open -> read from file -> choose wav that corresponds with this textgrid
# 4) ""                                     select the grid and the sound together -> view and edit

## SETUP ####################################################################
# target directory with computed alignments
expdir=exp/alignment
# stage
stage=0
#############################################################################

. utils/parse_options.sh

if [ $stage -le 0 ]; then
  echo "#### ADDING HEADERS TO ALIGNMENT FILES ###########"

  header="startutt_col channel start dur phone"
  headerfile=local/header.txt

  rm -f $headerfile
  echo $header > $headerfile

  randfile=$(find $expdir/alignments_per_utterance -type f -print0 | shuf -zn1)  #random ali file
  firstline=$(head -n 1 $randfile)

  # check if header is already there, otherwise don't append
  if [ "$header" != "$firstline" ]; then
    mkdir -p tmp
    echo "Headers not present yet, appending them... (takes a minute)"
    for i in $expdir/alignments_per_utterance/*.txt; do
      cat "$headerfile" "$i" > tmp/xx.$$
      mv tmp/xx.$$ "$i"
    done
    rm -rf tmp
  fi
fi

if [ $stage -le 1 ]; then
  echo "#### MAKING PRAAT TEXTGRIDS OF PHONE ALIGNMENT ###"
  mkdir -p $expdir/textgrids
  # edit the setup inside the .praat script to your own!
  praat local/createtextgrid.praat
fi

if [ $stage -le 2 ]; then
  echo "#### MAKING PRAAT TEXTGRIDS OF WORD ALIGNMENT ####"
  mkdir -p $expdir/wordtextgrids
  # edit the setup inside the .praat script to your own!
  praat local/createWordtextgrid.praat
fi

if [ $stage -le 3 ]; then
  echo "#### STACKING PHONE AND WORD TEXTGRIDS ###########"
  mkdir -p $expdir/stackedtextgrids
  # edit the setup inside the .praat script to your own!
  praat local/stacktextgrids.praat
fi

echo "ALL DONE"

