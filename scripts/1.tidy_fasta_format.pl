#! /usr/bin/perl -w
use strict;

open IN,"<$ARGV[0]" or die $!;
open OUT,">$ARGV[1]" or die $!;

my $tmp;
my %gene;
while(<IN>){
	chomp;
	if(/>(\S+)/){
		$tmp=$1;
		next;
	}
	$gene{$tmp}.=$_;
}
close IN;

foreach my $key(sort keys %gene){
	print OUT ">$key\n$gene{$key}\n";
}
