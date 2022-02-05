#!/bin/bash
# vim: set et tw=0:

# Joseph Harriott  Sat 05 Feb 2022

# grab all imagey files flattened out
# -----------------------------------
#  bash $onGH/underscores/imageyFlat.sh

# set as preferred
targetParentDir=/mnt/SD480GSSDPlus/Play0

jHM=$(date "+%j-%H%M%S")
[[ -w $targetParentDir ]] || targetParentDir=$HOME
targetDir="$targetParentDir/imageyFlat-$jHM"
mkdir "$targetDir"

# comment out if necessary
# imageyMovies='\|avi\|mkv\|mov\|mp4\|ogv'
imageyStills='\|gif\|jpeg\|jpg\|png'

allOrs=$imageyMovies$imageyStills
regex=${allOrs:2}  # gets rid of first spurious \|

imageyfiles=$(find . -iregex ".*\.\($regex\)$")

errors="$targetParentDir/imageyFlat-$jHM-errors.log"
[[ -f "$errors" ]] && rm $errors
echo "vim: tw=0:" > $errors
echo "" >> $errors

for if0 in $imageyfiles; do
  if1=${if0/.\//}
  if2=${if1//\//--}
  # echo $if2  # for checking
  cp $if0 "$targetDir/$if2" 2>> $errors
done
gvim $errors
echo "- output's in $targetDir"

