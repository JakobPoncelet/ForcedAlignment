#!/bin/bash

# THIS SCRIPT PREPARES THE TEXT/UTT2SPK/WAV.SCP FILES FOR GRABO. Run from one folder higher.

database=$1
datadir=$2
shift 2
valid_spk=$@  #$@ are all arguments, and shift 2 deletes the first 2

if ! [ -d $datadir ]; then
  mkdir $datadir
fi

if [ ! -f ./lexicon.txt ]; then
  echo "The directory doesn't contain lexicon.txt! Stopping."
  exit 1
fi

rm -f $datadir/text $datadir/wav.scp $datadir/utt2spk $datadir/new_lexicon.txt $datadir/lexicon.txt

echo "Creating and concatenating text/wav/utt2spk files..."

# This is specific for the structure of the database, in this case GRABO
for speaker in $valid_spk; do
  echo $speaker
  speakerdir=$database/speakers/$speaker
  for recordingdir in $speakerdir/spchdatadir/recording*; do
    recording=$(basename $recordingdir)
    for uttpath in $recordingdir/*.wav; do
      utt=$(basename $uttpath)
      utt="${utt%.*}"
      echo "$speaker"-"$recording"_"$utt sox -t wav $uttpath -b 16 -r 16000 -c 1 -t wav - remix - |" >> $datadir/wav.scp  #resample to 16kHz and make mono with remix (as used for acoustic model)
    done
  done
  for recordingdir in $speakerdir/transcriptions/recording*; do
    recording=$(basename $recordingdir)
    for uttpath in $recordingdir/*.txt; do
      utt=$(basename $uttpath)
      utt="${utt%.*}"
      trans=$(cat $uttpath)
      echo "$speaker"-"$recording"_"$utt $trans" >> $datadir/text
      echo "$speaker"-"$recording"_"$utt $speaker" >> $datadir/utt2spk
    done
  done
done

local/usascii-to-utf8.pl $datadir/text

cut -d ' ' -f 2- $datadir/text | sed 's/ /\n/g' | sort -u > $datadir/words.txt  #list of all words in text

cp ./lexicon.txt $datadir
python local/filter_dict.py $datadir  #if you want to make a new lexicon that deletes all the words not used in the new data, also prints oov words

if ! grep -q "^<oov>" $datadir/new_lexicon.txt; then
	echo -e "<oov>\t<oov>" >>$datadir/new_lexicon.txt
fi
