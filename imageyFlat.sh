#!/bin/bash
# vim: set et tw=0:

# Joseph Harriott  Tue 10 Mar 2020

# grab all imagey files flattened out
# -----------------------------------
#  bash -x /mnt/SDSSDA240G/Dropbox/JH/IT_stack/onGitHub/underscores/imageyFlat.sh

if [ -d "imageyFlat" ]; then rm -r imageyFlat; fi
mkdir "imageyFlat"

imageyfiles=$(find . -iregex '.*\.\(avi\|gif\|jpeg\|jpg\|mkv\|mov\|mp4\|ogv\|png\)$')

if [ -f "imageyFlat-errors.log" ]; then rm imageyFlat-errors.log; fi
echo "vim: tw=0:" > imageyFlat-errors.log
echo "" >> imageyFlat-errors.log

for if0 in $imageyfiles; do
  if1=${if0/.\//}
  if2=${if1//\//--}
  # echo $if2
  # cp $if0 "imageyFlat/$if2"
  cp $if0 "imageyFlat/$if2" 2>> imageyFlat-errors.log
done

