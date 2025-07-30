#!/usr/bin/perl

# Joseph Harriott - https://harriott.github.io/ - Wed 30 Jul 2025

# This script looks recursively at all files and directories in the current directory,
# and prints out the list found, but with these changes:
# - File (not directory) extensions: lowercased, and any leading blankspaces removed
# - Basenames (= file or directory name without extension):
# - - blanks around hyphens removed (my preference visually, but not easily reversible)
# - - and trailing blanks removed
# - - internal blankspaces converted to underscores
# - - if the target exists, an underscore is appended with a count
# As this could do a lot of damage, there's a query to simulate, or to go ahead, or quit.

# Prerequisites:  a system with Perl on.

# in the directory to change,  perl $onGH/FM-underscores/underscores.pl

# Accents in filename, like `é` are handled correctly,
# though the changes reported in a Windows console may look odd
# and I now change out accented stuff - see below.

# Caveat: this may silently fail to rename folders monitored by Dropbox.

use strict;  use warnings;  use File::Basename;  use File::Copy 'move';
use File::Find; # finddepth()

# First, create a time check:
END { print "This Perl program ran for ", time() - $^T, " seconds.  All changes reported.\n"}

# Next, warn what's about to be done:
print "You are about to recursively rename files and directories!  Enter  to quit, or  g  to go ahead: ";
my $resp = <STDIN>;
chomp $resp; # Get rid of newline character at the end
if ($resp ne "g") { print "Quit!  "; exit 0; } else { print "Working...\n"; }

# Now do all the work:
print "Okay, these are the original branches with their renamed leafs:\n";
finddepth({ wanted => \&allds, no_chdir => 1 }, "."); # dots in dirs
finddepth({ wanted => \&allds, no_chdir => 1 }, "."); # dots in lower dirs
finddepth({ wanted => \&allfods, no_chdir => 1 }, ".");

sub allds {
  if (-d $_) {
    if (length($_) > 1) {
      my $dnf = $_;
      $dnf =~ s/(.)\./$1_/g; # directory name fixed
      if ($_ ne $dnf) {
        my $tc = 0;
        while (-d $dnf) {
          $tc++;
          $dnf = $dnf."_".$tc;  # - added a count if target exists
        }
        move $_, $dnf;
        # print "$_\n$dnf\n"; # - reports the changes done
      }
    }
  };
} # change . to _ in directory names - repeat for deeper levels

sub allfods {
  my ($fodbn,$dir,$ext) = fileparse($_, qr/\.[^.]*/); # $_  defined by  File::Find
  my $fod0 = $dir.$fodbn.$ext;
  if (-f $_) {$ext = lc($ext)}; # lowercase
  $fodbn =~ s/\s+-/-/g; # strip out blanks before hyphens
  $fodbn =~ s/-\s+/-/g; # strip out blanks after hyphens
  $fodbn =~ s/\s+_/_/g; # strip out blanks before underscores
  $fodbn =~ s/_\s+/_/g; # strip out blanks after underscores
  $fodbn =~ s/\s+$//g; # strip off trailing blanks
  $fodbn =~ s/\s+/_/g; # convert all inner blanks to underscores
  $fodbn =~ s/à/a/g; # remove French stuff
  $fodbn =~ s/è/e/g; # remove French stuff
  $fodbn =~ s/É/E/g; # remove French stuff
  $fodbn =~ s/é/e/g; # remove French stuff
  $fodbn =~ s/ê/e/g; # remove French stuff
  $fodbn =~ s/ï/i/g; # remove French stuff
  $fodbn =~ s/'/_/g; # remove French stuff
  $fodbn =~ s///g; # ZNc
  $ext =~ s/\.\s+/\./g;  # - take out any weirdly present blanks
  my $fod1 = $dir.$fodbn.$ext;
  if ($fod0 ne $fod1) {
    my $tc = 0;
    while (-e $fod1) {
      $tc++;
      $fod1 = $dir.$fodbn."_".$tc.$ext;  # - added a count if target exists
    }
    move $fod0, $fod1;
    # print "$fod1\n"; # - reports the changes done
  }
} # fix all file or directory names

