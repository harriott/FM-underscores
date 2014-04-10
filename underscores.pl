#!/usr/bin/perl
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

# Drop this file into the parent folder that you want to work on, open a Terminal there,
# enter the name of this file, hit return, and watch the progress!

# Caveat: this may silently fail to rename folders monitored by Dropbox.

use strict;  use warnings;  use File::Basename;  use File::Copy 'move';  use File::Find;

# First, create a time check:
END { print "This Perl program ran for ", time() - $^T, " seconds.  All changes reported.\n"}

# Next, warn what's about to be done:
print "You are about to recursively rename files and directories: spaces to underscores!\n";
print "This may be difficult to reverse!\n";
print "Enter g to go ahead, s to simulate, or just Enter to quit: ";
my $resp = <STDIN>;
chomp $resp; # Get rid of newline character at the end
if ($resp ne "g") {
	if ($resp eq "s") {
		print "Simulating...\n";
	} else {
		print "Quit!  ";
		exit 0;
	}
} else {
print "Working...\n";
}

# Now do all the work:
print "Okay, these are the original branches with their renamed leafs:\n";
finddepth({ wanted => \&allfods, no_chdir => 1 }, ".");   # finished!
if ($resp eq "s") {
	print "hit Enter to quit";
	<STDIN>;
}

#  The subroutine to adjust all file or directory names:
sub allfods {
	my ($fodbn,$dir,$ext) = fileparse($_, qr/\.[^.]*/);
	my $fod0 = $dir.$fodbn.$ext;
	if (-f $_) {$ext = lc($ext)};
	$fodbn =~ s/\s+-/-/g;   # - stripped out blanks before hyphens
	$fodbn =~ s/-\s+/-/g;   # - stripped out blanks after hyphens
	$fodbn =~ s/\s+$//g;   # - stripped off trailing blanks
	$fodbn =~ s/\s+/_/g;   # - converted all inner blanks to underscores
	$ext =~ s/\.\s+/\./g;  # - took out any weirdly present blanks
	my $fod1 = $dir.$fodbn.$ext;
	my $ec = 0;
	if ($fod0 ne $fod1) {
		while (-e $fod1) {
			$ec++;
			$fod1 = $dir.$fodbn."_".$ec.$ext;  # - added a count if target exists
		}
		if ($resp eq "g") { move $fod0, $fod1; }
		print "$fod1\n";  # - reports the changes done
	}
}
