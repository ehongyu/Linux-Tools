#!/usr/bin/perl

## similar find.pl, but it can replace an old string with a new one

@foundFiles = ();

if($#ARGV != 1) {
	print "  ERROR! \n";
	print "  correct format: findReplace.pl \"old_string\" \"new_string\"\n";
	exit 1;
}

open(FIND, "find . -print |") || die "Couldn't run find: $!\n";

FILE:
while ($filename=<FIND>) {
	chop $filename;
	next FILE unless -T $filename;
	if(!open(TEXTFILE, $filename)) {
		print STDERR "Can't open $filename-continueing...\n";
		next FILE;
	}
	while(<TEXTFILE>){
		if(index($_,$ARGV[0]) >= 0) {
			@foundFiles = (@foundFiles, $filename);
			next FILE;
		}
	}
}

print "\n";

if($#foundFiles < 0) {
	print "No files contain the string \"$ARGV[0]\":\n\n";
}
else {
	print "The following files contain the string \"$ARGV[0]\":\n";

	for($i=0; $i<=$#foundFiles; $i++) {
		print $foundFiles[$i], "\n";
	}

	print "\n";

	for(;;) {
		print "Are you sure that you want to replace them with the new string \"$ARGV[1]\"?[Y/N]\n";
		read STDIN, $answer, 1;
		$tmp=<STDIN>;

		if($answer eq "y" || $answer eq "yes" ||
		   $answer eq "Y" || $answer eq "Yes" ) {
			for($j=0; $j<=$#foundFiles; $j++) {
				if($foundFiles[$j] !~ /.orig/) {
					replace($foundFiles[$j]);
				}
			}
			last;
		}
		elsif($answer eq "n" || $answer eq "no" ||
		      $answer eq "N" || $answer eq "No" ) {
			last;
		}	
		else {
			next;
		}
	}	

}

# subroutine of string replacement

sub replace($filename)
{
	$filename = @_[0];
	open(FINDFILE, $filename) || die "Couldn't open $filename\n";
	open(REPLFILE, ">$filename.rep") || die "Couldn't open $filename.rep\n";
	while(<FINDFILE>){
		s/$ARGV[0]/$ARGV[1]/g;
		print REPLFILE;
	}	
	close FINDFILE;
	close REPLFILE;

	link $filename, "$filename.orig";
	unlink $filename;
	link "$filename.rep", $filename;
	unlink "$filename.rep";
	$mode = oct(sprintf "%04o\n", (stat $filename)[2] & 07777);
	chmod $mode, $filename;
}
