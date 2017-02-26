#! /usr/bin/perl -w
use strict;

### By xiongxs, edited to calculate the distribution of intron/exon; 

open IN,$ARGV[0] or die $!;   ## The annotatePeak.pl annotated file
open IN2,"/rd/user/masq/xiongxs/Genome_data/human/refseq_0906/hg19_refseq.bed" or die $!;
open OUT,">$ARGV[1]" or die $!;

my %exon;
my %intron;
while(<IN>){
	chomp;
	my @sp=split /\t/;
	next if !/chr/;
	next if $sp[7]=~ /TTS|Intergenic/;
	my $tmp=int(($sp[2]+$sp[3])/2);
	if($sp[7]=~ /promoter-TSS/){
		my $id;
		if($sp[7]=~ /\((\S+)\)/){$id=$1;}
		if($sp[4] eq "+" && $sp[9]>=0 && $sp[9]<=100){
			$exon{$id}{$tmp}{$sp[0]}=1;
		}
		if($sp[4] eq "-" && $sp[9]<=0 && $sp[9]>=-100){
			$exon{$id}{$tmp}{$sp[0]}=1;
		}
		next;
	}
	if($sp[7]=~ /intron\s+\((\S+),\s+intron\s+(\d+)\s+of\s+\d+\)/){
		my $id=$1;
		my $num=$2;
		$intron{$id}{$tmp}{$sp[0]}=$num;
		next;
	}
	if($sp[7]=~ /\((\S+),\s+exon\s+(\d+)\s+of\s+\d+\)/){
		my $id=$1;
		my $num=$2;
		$exon{$id}{$tmp}{$sp[0]}=$num;
		next;
	}
}
	
while(<IN2>){
	chomp;
	my @sp=split /\s+/;
	if(exists $exon{$sp[3]}){
		foreach my $pos(sort {$a<=>$b} keys %{$exon{$sp[3]}}){
			foreach my $peak(sort  keys %{$exon{$sp[3]}{$pos}}){
				next if $pos<$sp[1] || $pos>$sp[2];
				my @leng=split /,/, $sp[10];
				my @splice=split /,/, $sp[11];
				if($sp[5] eq "+"){
				  my $tmp1=$pos-$sp[1];
				  my $tmp2=$tmp1-$splice[$exon{$sp[3]}{$pos}{$peak}-1];
				  my $perc=int($tmp2/$leng[$exon{$sp[3]}{$pos}{$peak}-1]*100000)/1000;
				  print OUT "$peak\t$sp[3]\texon\t$tmp2\t$leng[$exon{$sp[3]}{$pos}{$peak}-1]\t$perc\t+\n";
				}
				if($sp[5] eq "-"){
					my $tmp1=$pos-$sp[1];
					my $tmp2=$tmp1-$splice[-$exon{$sp[3]}{$pos}{$peak}];
					my $tmp3=$leng[-$exon{$sp[3]}{$pos}{$peak}]-$tmp2;
					my $perc=int($tmp3/$leng[-$exon{$sp[3]}{$pos}{$peak}]*100000)/1000;
					print OUT "$peak\t$sp[3]\texon\t$tmp3\t$leng[-$exon{$sp[3]}{$pos}{$peak}]\t$perc\t-\n";
				}

			}
		}
	}
	if(exists $intron{$sp[3]}){
		foreach my $pos(sort {$a<=>$b} keys %{$intron{$sp[3]}}){
			foreach my $peak(sort keys %{$intron{$sp[3]}{$pos}}){
				next if $pos<$sp[1] || $pos>$sp[2];
				my @leng=split /,/, $sp[10];
				my @splice=split /,/, $sp[11];
				if($sp[5] eq "+"){
					my $tmp1=$pos-$sp[1];
					my $tmp2=$tmp1-$splice[$intron{$sp[3]}{$pos}{$peak}-1]-$leng[$intron{$sp[3]}{$pos}{$peak}-1];
					my $intron_leng=$splice[$intron{$sp[3]}{$pos}{$peak}]-$splice[$intron{$sp[3]}{$pos}{$peak}-1]-$leng[$intron{$sp[3]}{$pos}{$peak}-1];
					my $perc=int($tmp2/$intron_leng*100000)/1000;
					print OUT "$peak\t$sp[3]\tintron\t$tmp2\t$intron_leng\t$perc\t+\n";
				}
				if($sp[5] eq "-"){
					my $tmp1=$pos-$sp[1];
					my $tmp2=$splice[-$intron{$sp[3]}{$pos}{$peak}]-$tmp1;
					my $intron_leng=$splice[-$intron{$sp[3]}{$pos}{$peak}]-$splice[-$intron{$sp[3]}{$pos}{$peak}-1]-$leng[-$intron{$sp[3]}{$pos}{$peak}-1];
					my $perc=int($tmp2/$intron_leng*100000)/1000;
					print OUT "$peak\t$sp[3]\tintron\t$tmp2\t$intron_leng\t$perc\t-\n";
				}
			}
		}
	}
}



