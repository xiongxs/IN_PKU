#! /usr/bin/perl -w
use strict;

## By Xushen Xiong, edited to covert transcript position to genomic position, providing a gtf file

open IN1,"$ARGV[0]" or die $!;   ## The transcript pos file
open IN2,"$ARGV[1]" or die $!;   ## The gtf file

my %pos;
<IN1>;
while(<IN1>){
	chomp;
	my @sp=split /\s+/;
#	if($sp[0]=~ /hg19_refGene_(\S+)/){
		$pos{$sp[0]}{$sp[1]}=$_;
#	}
}
close IN1;

open OUT,">$ARGV[2]" or die $!;
my %tmp;
my %minus;
my %chr;
my %sign;
my $ab='abc';
while(<IN2>){
	chomp;
	next if !/exon/;
	my @sp=split /\s+/;
	my $id;
	if(/gene_id\s+"(\S+)";/){
		$id=$1;
		next if !exists $pos{$id};
	}
	next if exists $sign{$id};
	if($ab ne $id){
		$sign{$ab}=1;
	}
	if($sp[6] eq "+"){
		my $leng;
		foreach my $key(sort {$a <=> $b} keys %{$pos{$id}}){
			$tmp{$id}=0 if !exists $tmp{$id};
			$leng=$sp[4]-$sp[3]+1;
			if($key<=$tmp{$id}+$leng && $key>$tmp{$id}){
				my $over=$key-$tmp{$id};
				my $G_pos=$sp[3]+$over-1;
				print OUT "$sp[0]\t$G_pos\t+\t$pos{$id}{$key}\n";
			}
		}
		$tmp{$id}+=$leng;

	}
	if($sp[6] eq "-"){
		$chr{$id}=$sp[0];
		$minus{$id}.="$sp[3]---$sp[4]\t";
	}
	$ab=$id;
}
close IN2;

foreach my $id(sort keys %minus){
	my @sp=split /\s+/, $minus{$id};
#	print "$sp[-1]\n";
	for(my $i=-1;;$i--){
		last if !defined $sp[$i];
		my @p=split /---/, $sp[$i];
		my $leng;
		foreach my $key(sort {$a <=> $b} keys %{$pos{$id}}){
			$tmp{$id}=0 if !exists $tmp{$id};
			$leng=$p[1]-$p[0]+1;
			if($key<=$tmp{$id}+$leng && $key>$tmp{$id}){
				my $over=$key-$tmp{$id};
				my $G_pos=$p[1]-$over;
				print OUT "$chr{$id}\t$G_pos\t-\t$pos{$id}{$key}\n";
			}
		}
		$tmp{$id}+=$leng;
	}
}
close OUT;

		

