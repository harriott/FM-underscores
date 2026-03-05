# vim: set fdl=5:

# Joseph Harriott  jeu 05 mars 2026
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
  $ndrl = $ndrl -creplace 'À','A'
  $ndrl = $ndrl -creplace 'à','a'
  $ndrl = $ndrl -creplace 'ç','c'
  $ndrl = $ndrl -creplace 'É','E'
  $ndrl = $ndrl -creplace 'è|é|ê|ë','e'
  $ndrl = $ndrl -creplace 'Ï','I'
  $ndrl = $ndrl -creplace 'î|ï','i'
  $ndrl = $ndrl -creplace 'œ','oe'
  $ndrl = $ndrl -creplace 'ù','u'
  $ndrl = $ndrl -replace '',''
  $ndrl = $ndrl -replace ' | ','_' # space & no-break space
  $ndrl = $ndrl -replace '–','-' # en dash
  $ndrl = $ndrl -replace '_+','_'
  $ndrl = $ndrl -replace '_-_','-'
  if ($ndrl -ne $drl) {
    $ndrlno = "$drr/$ndrl" -replace '\./','' # $ndrl  name only
    mv "$drr/$drl" "$drr/$ndrl"
    write-color -text $drl,'->',$ndrlno -color DarkGreen,DarkYellow,White
  }
}
write-host '- all done'

'Now, file name fixes:'
$files = ls -af -s * | select -expand FullName
foreach ($file in $files) {
  $fr = $file.substring($wd.length+1) # file relative
  $frf = $fr -replace ' | ','_' # file relative fixed for space & no-break space
  $frf = $frf -replace "'|’",'_' # replace any single quotes
  $frf = $frf -creplace 'À|à','A'
  $frf = $frf -creplace 'à','a'
  $frf = $frf -creplace 'ç','c'
  $frf = $frf -creplace 'É','E'
  $frf = $frf -creplace 'è|é|ê|ë','e'
  $frf = $frf -creplace 'Ï','I'
  $frf = $frf -creplace 'ï','i'
  $frf = $frf -creplace 'œ','oe'
  $frf = $frf -creplace 'ù','u'
  $frf = $frf -replace '–|：','-' # en dash, fullwidth colon
  $frf = $frf -replace '_-_','-'
  if ( $frf -match '\[' ) {
    $fr = $fr -replace "\[",'`[' # backtick the [
    $frf = $frf -replace "\[",'_'
  }
  if ( $frf -match '\]' ) {
    $fr = $fr -replace ']','`]' # backtick the ]
    $frf = $frf -replace ']','_'
  }
  $frf = $frf -replace '_+','_'
  $frf = $frf -replace '\\_','\\'
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
}
write-host '- all done'

