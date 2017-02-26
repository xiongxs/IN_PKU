#! /usr/bin/perl -w
use strict;

### Edited to convert the maf file from ucsc to fasta file

## Usage: perl $0 input.maf output.fa

open IN,"<$ARGV[0]" or die $!;      ## The maf file downloaded from UCSC 
open OUT,">$ARGV[1]" or die $!;     ## output.fa

my %seq;
my @sort;

while(<IN>){
	chomp;
	if(/^s\s+(\S+)/){
		my $spc=$1;
		if(!exists $seq{$spc}){
			my $size=@sort;
			$sort[$size]=$spc;
		}
		my @sp=split /\s+/;
		$sp[6]=~ s/-//g;
		$seq{$spc}.= $sp[6];
	}
}

for(my $i=0;;$i++){
	last if !defined $sort[$i];
	print OUT ">$sort[$i]\n$seq{$sort[$i]}\n";
}

