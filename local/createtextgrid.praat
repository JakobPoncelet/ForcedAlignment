# This script creates praat textgrids from the phone alignments (locations are rather specific for the GRABO dataset).


## SETUP ##########################################################
# where alignments per utterance have been generated
dir$ = "/users/spraak/jponcele/GRABO/exp/alignment/alignments_per_utterance"
# wav files of new dataset
dir2$ = "/users/spraak/spchdata/grabo/speakers"
# where to store the textgrids
dir3$ = "/users/spraak/jponcele/GRABO/exp/alignment/textgrids"
###################################################################


Create Strings as file list... list_txt 'dir$'/*.txt
nFiles = Get number of strings

for i from 1 to nFiles
	select Strings list_txt
	filename$ = Get string... i
	basename$ = filename$ - ".txt"
	txtname$ = filename$ - ".txt"
	hy1 = index(basename$, "-")
	speaker$ = left$(basename$,hy1-1)
	len1 = length: basename$
	tmpname$ = mid$(basename$,hy1+1,len1)
	hy2 = index(tmpname$, "_")
	recordname$ = left$(tmpname$,hy2-1)
	len2 = length: tmpname$
	wavname$ = mid$(tmpname$,hy2+1,len2)
	Read from file... 'dir2$'/'speaker$'/spchdatadir/'recordname$'/'wavname$'.wav
	Rename... soundFileObj
	dur = Get total duration
	To TextGrid... "kaldiphone"
	Rename... 'basename$'
	#pause 'txtname$'

	select Strings list_txt
	Read Table from whitespace-separated file... 'dir$'/'txtname$'.txt
	#writeInfoLine: basename$
	Rename... times
	nRows = Get number of rows
	Sort rows... start
	for j from 1 to nRows
		select Table times
		startutt_col$ = Get column label... 1
		start_col$ = Get column label... 3
		dur_col$ = Get column label... 4
		phone_col$ = Get column label... 5
		if j < nRows
			startnextutt = Get value... j+1 'startutt_col$'
		else
			startnextutt = 0
		endif
		start = Get value... j 'start_col$'
		phone$ = Get value... j 'phone_col$'
		dur = Get value... j 'dur_col$'
		end = start + dur
		select TextGrid 'basename$'
		int = Get interval at time... 1 start+0.005
		if start > 0 & startnextutt = 0
			Insert boundary... 1 start
			Set interval text... 1 int+1 'phone$'
			Insert boundary... 1 end
		elsif start = 0
			Set interval text... 1 int 'phone$'
		elsif start > 0
			Insert boundary... 1 start
			Set interval text... 1 int+1 'phone$'
		endif
		#pause
	endfor
	#pause
	Write to text file... 'dir3$'/'basename$'.TextGrid
	select Table times
	plus Sound soundFileObj
	plus TextGrid 'basename$'
	Remove
endfor
