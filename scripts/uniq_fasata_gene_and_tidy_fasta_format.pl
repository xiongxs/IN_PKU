#! /usr/bin/perl -w
use strict;

#edited to remove the redundant genes, and in the same time tidy the fasata format

open IN,"<$ARGV[0]" or die $!;
open OUT,">$ARGV[1]" or die $!;

#$/ = ">";
my %gene;
while(<IN>){
	chomp;
	next if /^$/;
	if(/>(\S+)/){
		my $tmp=$1;
		next if exists $gene{$tmp};
		$gene{$tmp}=1;
		print OUT "\n$_\n";
		next;
	}
	if(/(\S+)/){
		print OUT "$1";
	}
}

