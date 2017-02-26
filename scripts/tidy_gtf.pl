#! /usr/bin/perl -w
use strict;

open IN,"mm10_refgene.gtf" or die $!;
open OUT,">mm10_refgene.tidy.gtf" or die $!;

print OUT "gene\tchr\tstrand\tcds_start\tcds_end(stopcodon_included)\ttranscript_length\tgene_name\n";
my %gene;
while(<IN>){
	chomp;
	next if /^#/;
	my @sp=split /\s+/;
#	if($sp[3] eq "+"){
	my @start=split /,/,$sp[9];
	my @end=split /,/,$sp[10];
	my $cds=0;
	my $start_codon=0;
	my $end_codon=0;
	if($sp[3] eq "+"){
		for(my $i=0;;$i++){
			last if $i==$sp[8];
			if($sp[6]>=$start[$i] && $sp[6]<$end[$i]){
				$start_codon=$sp[6]-$start[$i]+1+$cds;
			}
			if($sp[7]>=$start[$i] && $sp[7]<=$end[$i]){
				$end_codon=$sp[7]-$start[$i]+$cds;
			}
			$cds+=$end[$i]-$start[$i];
		}
		print OUT "$sp[1]\t$sp[2]\t$sp[3]\t$start_codon\t$end_codon\t$cds\t$sp[12]\n";
	}
	if($sp[3] eq "-"){
		for(my $i=$sp[8]-1;;$i--){
			last if $i== -1;
			if($sp[6]>=$start[$i] && $sp[6]<$end[$i]){
				$end_codon=$end[$i]-$sp[6]+$cds;
			}
			if($sp[7]>=$start[$i] && $sp[7]<=$end[$i]){
				$start_codon=$end[$i]-$sp[7]+1+$cds;
			}
			$cds+=$end[$i]-$start[$i];
		}
		print OUT "$sp[1]\t$sp[2]\t$sp[3]\t$start_codon\t$end_codon\t$cds\t$sp[12]\n";
	}
}
close IN;



