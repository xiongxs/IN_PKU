#! /usr/bin/perl -w
use strict;

open IN,"samtools view -F 256 $ARGV[0] | " or die $!;
open OUT,">$ARGV[1]" or die $!;

my $total=0;
my $map=0;
my $rRNA=0;
my $NR=0;
my $NM=0;

while(<IN>){
	chomp;
	my @sp=split /\s+/;
	$total++;
	$map++ if $sp[2] ne "*";
	if($sp[2]=~ /rRNA/){
		$rRNA++;
		next;
	}
	if($sp[2]=~ /NR_/){
		$NR++;
	}
	if($sp[2]=~ /NM_/){
		$NM++;
	}
}

my $map_per=int($map/$total*10000)/100;
my $rRNA_per=int($rRNA/$total*10000)/100;;
my $NR_per=int($NR/$total*10000)/100;;
my $NM_per=int($NM/$total*10000)/100;;

print OUT "total\t$total\nmapped\t$map\t$map_per\nrRNA\t$rRNA\t$rRNA_per\nNR\t$NR\t$NR_per\nNM\t$NM\t$NM_per\n";



