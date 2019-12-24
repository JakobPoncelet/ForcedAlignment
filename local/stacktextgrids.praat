# This script stacks two TextGrids to create one. 


## SETUP ##########################################################
# location of phone textgrids
dir$ = "/users/spraak/jponcele/GRABO/exp/alignment/textgrids"
# location of word textgrids
dir2$ = "/users/spraak/jponcele/GRABO/exp/alignment/wordtextgrids"
# where to store the stacked textgrids
dir3$ = "/users/spraak/jponcele/GRABO/exp/alignment/stackedtextgrids"
###################################################################

Create Strings as file list... gridlist 'dir$'/*.TextGrid
Sort
n = Get number of strings

for i from 1 to n
	select Strings gridlist
	file$ = Get string... i
	base$ = file$ - ".TextGrid"
	
	Read from file... 'dir$'/'base$'.TextGrid
	Rename... file1
	
	Read from file... 'dir2$'/'base$'_word.TextGrid
	Rename... file2

	select TextGrid file1
	plus TextGrid file2
	Merge
	Write to text file... 'dir3$'/'base$'_final.TextGrid
	select TextGrid file1
	plus TextGrid file2
	plus TextGrid merged
	
	Remove
	#i = i+1
endfor
