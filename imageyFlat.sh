#!/bin/bash
# vim: set sw=2:

# Joseph Harriott  Fri 25 Jul 2025

# grab all imagey files flattened out
# -----------------------------------
#  bash $onGH/FM-underscores/imageyFlat.sh

targetParentDir="$HOME/Play0"
if [ $targetParentDir ]; then
  jHM=$(date "+%y%m%d-%H%M%S")
  targetDir="$targetParentDir/imageyFlat-$jHM"
  mkdir "$targetDir"

  # comment out if necessary
  # imageyMovies='\|avi\|mkv\|mov\|mp4\|ogv'
  imageyStills='\|gif\|jpeg\|jpg\|png\|svg'

  regexes=$imageyMovies$imageyStills
  regex=${regexes:2}  # gets rid of first spurious \|

  mapfile -t imageyfiles < <(find . -iregex ".*\.\($regex\)$")
  # for if in "${imageyfiles[@]}"; do echo "$if"; done  # for checking

  errors="$targetParentDir/imageyFlat-$jHM-errors.log"
  [[ -f "$errors" ]] && rm $errors
  echo "vim: tw=0:" > $errors
  echo "" >> $errors

  i=0
  for if in "${imageyfiles[@]}"; do
    ((i+=1))
    iff="$if"
    iff=${iff/.\//}
    iff=${iff//\//--}
    iff=${iff// /_}
    # echo "$iff"  # for checking
    cp "$if" "$targetDir/$iff" 2>> $errors
  done
  # gvim $errors
  echo "- $i output's in $targetDir"
else
  echo "no  $targetParentDir"
fi

