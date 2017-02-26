#! /usr/bin/perl -w
use strict;

open IN,"samtools view $ARGV[0] | " or die $!;   ## The bam file
open IN2,"/rd/user/masq/xiongxs/Genome_data/human/gene_annotation/hg19_refGenes.snRNA.tRNA.annotation.xls" or die $!;
open OUT,">$ARGV[1]" or die $!;

my %nm;
<IN2>;
while(<IN2>){
	chomp;
	my @sp=split /\s+/;
	if($sp[0]=~ /NM_/){
		next if exists $nm{$sp[0]};
		$nm{$sp[0]}=$sp[2];
	}
}
close IN2;

my @perc;
for(my $i=0;;$i++){
	last if $i==100;
	$perc[$i]=0;
}

while(<IN>){
	chomp;
	my @sp=split /\s+/;
	next if !exists $nm{$sp[2]};
	my $tmp=int($sp[3]/$nm{$sp[2]}*100);
	$perc[$tmp]++;
}
close IN;

my $total=0;
for(my $i=0;;$i++){
	last if $i==100;
	$total+=$perc[$i];
}

for(my $i=0;;$i++){
	last if $i==100;
	my $tmp=int($perc[$i]/$total*100000)/1000;
	print OUT "$i\t$perc[$i]\t$tmp\n";
}






