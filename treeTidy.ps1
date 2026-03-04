# vim: set fdl=5:

# Joseph Harriott  mer 04 mars 2026
# $onGH/FM-underscores/treeTidy.ps1

# (internally) lists all of the current directory structure, (internally) rearranges it, then, working from the leaves to the root, fixes issues in node names

# Write-Host 'About to recursively fix naming issues in the whole directory tree ' -NoNewline
# [System.Console]::ForegroundColor = 'Yellow'
# $reply = read-host '- are you in the right parent directory? '
# [System.Console]::ResetColor()
# if ($reply -ne 'y') { return }

$dirs = ls -ad -s * | select -expand FullName | sort { $_.Length } -Descending
$wd = [string]$pwd
'First, directory name fixes, progressing from longest to shortest:'
foreach ($dir in $dirs) {
  $dr = $dir.substring($wd.length+1) # directory relative
  if ( $dr -match '\\' ) { $drr = $dr -replace '\\([^\\]*)$', '' } else { $drr = '.' } # $dr root
  $drl = $dr -replace '^.*\\', '' # $dr leaf
  $ndrl = $drl -replace '\.','_'
  $ndrl = $ndrl -replace '"','' # remove any double quotes
  $ndrl = $ndrl -replace "'",'_' # replace any single quotes
  $ndrl = $ndrl -replace 'à','a'
  $ndrl = $ndrl -replace 'é','e'
  $ndrl = $ndrl -replace 'è','e'
  $ndrl = $ndrl -replace 'ê','e'
  $ndrl = $ndrl -replace 'ï','i'
  $ndrl = $ndrl -replace 'î','i'
  $ndrl = $ndrl -replace '',''
  $ndrl = $ndrl -replace ' ','_'
  $ndrl = $ndrl -replace '__','_'
  $ndrl = $ndrl -replace '_-_','-'
  if ($ndrl -ne $drl) {
    $ndrlno = "$drr/$ndrl" -replace '\./','' # $ndrl  name only
    # mv "$drr/$drl" "$drr/$ndrl"; "$drr/$ndrl" -replace '\./',''
    mv "$drr/$drl" "$drr/$ndrl"
    write-color -text $drl,'->',$ndrlno -color DarkGreen,DarkYellow,White
  }
}
write-host '- all done'

'Now, file name fixes:'
$files = ls -af -s * | select -expand FullName
foreach ($file in $files) {
  $fr = $file.substring($wd.length+1) # file relative
  $frf = $fr -replace ' ','_' # file relative fixed
  $frf = $frf -replace '_-_','-'
  $frf = $frf -replace "'",'_' # replace any single quotes
  $frf = $frf -replace "’",'_'
  $frf = $frf -replace "à",'a'
  $frf = $frf -replace "é",'e'
  $frf = $frf -replace "è",'e'
  $frf = $frf -replace "ê",'e'
  $frf = $frf -replace "ï",'i'
  $frf = $frf -replace "：",'-'
  if ( $frf -match '\[' ) {
    $fr = $fr -replace "\[",'`[' # backtick the [
    $frf = $frf -replace "\[",'_'
  }
  if ( $frf -match '\]' ) {
    $fr = $fr -replace "]",'`]' # backtick the ]
    $frf = $frf -replace "]",'_'
  }
  $frf = $frf -replace "_+",'_'
  if ($frf -ne $fr) {
    if ( test-path $frf ) {
      $frf = ($frf -replace '\.([^.]*)$', '-') + (ls $frf | select -expand extension)
      } # my target's already there, so add a hyphen
    mv $fr $frf
    write-color -text $fr, '->', $frf -color DarkGreen,DarkYellow,White
  }
  # Now deal with any extra .'s:
  $bn = ls $frf | select -expand basename
  if ( $bn -match '\.' ) {
    $dir = Split-Path -Path $frf -Parent
    $bnf = $bn -replace "\.",'_'
    if ($dir) { $db = "$dir/$bnf" } else { $db = $bnf }
    $frff = $db + (ls $frf | select -expand extension)
    mv $frf $frff; $frff
  }
  # Finally, get rid of any  .DS_Store
  if ( $frf -match '\.DS_Store' ) { rm $frf }
}
write-host '- all done'

