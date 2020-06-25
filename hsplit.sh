#!/bin/bash

##############################################################################
# ./hsplit.sh --F <number of files> <input root file>                        #
# ./hsplit.sh --E <number of entries per file> <input root file>             #
# ./hsplit.sh --B <approximate number of entries per file> <input root file> #
#                                                                            #
# E.G.: ./hsplit.sh --B 350000 recsis_76.root                                #
##############################################################################

#####
# ISSUES
# - it creates output files in the dir where script was executed
# - don't know how to edit/modify the tree name
####

#####
# Functions
###

function get_num()
{
  sr=$1
  srn=""
  if [[ $sr -lt 10 ]]; then
    srn="0$sr"
  else
    srn="$sr"
  fi
  echo $srn
}

#####
# Input
###

inputArray=("$@")

if [[ "${inputArray[0]}" == "--F" ]]; then
    option="F" # split in a exact number of files with the same number of entries and keeps remaining entries in the first file
    NFiles=${inputArray[1]}
elif [[ "${inputArray[0]}" == "--E" ]]; then
    option="E" # split in an exact number of entries per file and keeps remaining entries in the first file
    NEntries=${inputArray[1]}
elif [[ "${inputArray[0]}" == "--B" ]]; then
    option="B" # uses E option to obtain number of output files and then uses F to obtain number of entries per file (best option, imo)
    NEntries=${inputArray[1]}
else
    printf "\n*** Aborting: Unrecognized argument: ${inputArray[$((ic))]}. Please, check usage box inside code. ***\n\n";
fi

inputFile=${inputArray[2]}

#####
# Set number of files and entries
###

totalEntries=$(root -l -b -q ${inputFile} -e 'CLASEVENT->GetEntries()' | awk 'END{print $NF}')

if [[ "${option}" == "F" ]]; then
    NEntries=$(($totalEntries/$NFiles))
    NEntries_firstfile=$(($NEntries + $totalEntries%$NFiles))
elif [[ "${option}" == "E" ]]; then
    NFiles=$(($totalEntries/$NEntries))
    NEntries_firstfile=$(($NEntries + $totalEntries%$NEntries))
elif [[ "${option}" == "B" ]]; then
    NFiles=$(($totalEntries/$NEntries)) # uses E option
    NEntries=$(($totalEntries/$NFiles)) # uses F option
    NEntries_firstfile=$(($NEntries + $totalEntries%$NEntries)) # uses F option
fi

echo "totalEntries       = ${totalEntries}"
echo "NFiles             = ${NFiles}"
echo "NEntries           = ${NEntries}"
echo "NEntries_firstfile = ${NEntries_firstfile}"

#####
# Notes
###

# test case: (totalentries = 1405) -> --f 4
#
# -> nfiles = 4
# -> nentries = 1405/4 = 351
# -> nentries_ff = 351 + 1 = 352

# test case: (totalentries = 1405) -> --e 351
#
# -> nentries = 351
# -> nfiles = 1405/351 = 4
# -> nentries_ff = 351 + 1 = 352

#####
# Main
###

ic=0
while [[ $ic -le $(($NFiles - 1)) ]]; do
    # naming of output files start at 01
    rn=$(get_num "$(($ic+1))")
    outFile="${inputFile/.root}_${rn}.root"
    if [[ $ic -eq 0 ]]; then
	# first iteration
	low_limit=0
	high_limit=$(($low_limit + $NEntries_firstfile - 1))
    else
	# from second to last iteration
	low_limit=$(($NEntries_firstfile + $ic*$NEntries - $NEntries))
	high_limit=$(($low_limit + $NEntries - 1))
    fi
    # execute rooteventselector
    rooteventselector -f $low_limit -l $high_limit ${inputFile}:CLASEVENT ${outFile}
    echo "Created file ${outFile}"
    ((ic+=1))
done

#####
# Notes
###

# test case: (totalentries = 1405) -> --F 4
#
# it 0: [0 - 351], total=352      0+352-1=351
# it 1: [352 - 702], total=351    352+1*351-351=352  -> 352+351-1=702
# it 2: [703 - 1053], total=351   352+2*351-351=703  -> 703+351-1=1053
# it 3: [1054 - 1404], total=351  352+3*351-351=1054 -> 1054+351-1=1404
