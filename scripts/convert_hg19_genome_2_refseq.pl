#! /usr/bin/perl -w
use strict;

open IN,"$ARGV[0]" or die $!;
open IN2,"/rd/user/masq/xiongxs/Genome_data/human/refseq_0906/hg19_refseq_gene.gtf" or die $!;
open OUT,">$ARGV[1]" or die $!;

#chomp(my $header=<IN>);
#print OUT "geneid\tpos\t$header\n";

my %site;
while(<IN>){
	chomp;
	my @sp=split /\t/;
	$site{$id}{$sp[1]}{$sp[2]}=$_;
}

my %chr;
my %tmp;
my %minus;
my %sign;
my $ab="aaa";
while(<IN2>){
	chomp;
	my @sp=split /\s+/;
	next if $sp[2] !~/exon/;
#	print "$_\n";
	if(/gene_id\s+"(\S+)";/){
		my $id=$1;
		next if exists $sign{$id};
		if($ab ne $id){
			$sign{$ab}=1;
		}
		next if !exists $site{$id}{$sp[0]};
		if($sp[6] eq "+"){
			$tmp{$id}=0 if !exists $tmp{$id};
			foreach my $pos(sort {$a <=> $b} keys %{$site{$id}{$sp[0]}}){
				if($pos<=$sp[4] && $pos>=$sp[3]){
					my $overhang=$pos-$sp[3]+1+$tmp{$id};
					print OUT "$id\t$overhang\t$site{$id}{$sp[0]}{$pos}\n";
				}
			}
			$tmp{$id}+=$sp[4]-$sp[3]+1;
		}
		if($sp[6] eq "-"){
			$minus{$id}.="$sp[3]---$sp[4]\t";
			$chr{$id}=$sp[0];
		}
		$ab=$id;
	}
}

foreach my $id(sort keys %minus){
	my @sp=split /\s+/, $minus{$id};
	for(my $i=-1;;$i--){
		last if !defined $sp[$i];
		my @p=split /---/, $sp[$i];
		my $leng;
		foreach my $key(sort {$a <=> $b} keys %{$site{$id}{$chr{$id}}}){
			$tmp{$id}=0 if !exists $tmp{$id};
			$leng=$p[1]-$p[0]+1;
			if($key<=$p[1] && $key>=$p[0]){
				my $overhang=$p[1]-$key+1+$tmp{$id};
				print OUT "$id\t$overhang\t$site{$id}{$chr{$id}}{$key}\n";
			}
		}
		$tmp{$id}+=$leng;
	}
}




			

















