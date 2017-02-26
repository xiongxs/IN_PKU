#! /usr/bin/perl -w
use strict;

open IN,"/rd/user/masq/xiongxs/Genome_data/human/refseq_0906/hg19_refseq.bed" or die $!;
open IN2,$ARGV[0] or die $!;      # homer annotated file

my %sign;
while(<IN2>){
		chomp;
		my @sp=split /\t/;
		next if !/chr/;
		if( $sp[7]=~ /\((\w+),\s+exon\s+\d+\s+of\s+\d+\)/ || $sp[7]=~/TTS\s+\((\S+)\)/ || $sp[7]=~ /promoter-TSS\s+\((\S+)\)/ )  {
			my $id=$1;
			$sign{$id}=1;
		}
}
close IN2;

my %convert;
my %strand;
while(<IN>){
	chomp;
	my @sp=split /\s+/;
	$strand{$sp[3]}=$sp[5];
	next if !exists $sign{$sp[3]};
	if($sp[5] eq "+"){
		my @leng=split /,/,$sp[10];
		my @point=split /,/,$sp[11];
		my $j=1;  ## pos on transcript
		for(my $i=0;;$i++){
			last if $i==$sp[9];
#			my $j=1;  ## pos on transcript
			for(my $k=$sp[1]+$point[$i]+1;;$k++){
				last if $k>$sp[1]+$point[$i]+$leng[$i];
				$convert{$sp[3]}{$sp[0]}{$k}=$j;
#				print STDERR "$sp[3]\t$sp[0]\t+\t$k\t$j\n";
				$j++;
			}
		}
	}
	if($sp[5] eq "-"){
		my @leng=split /,/,$sp[10];
		my @point=split /,/,$sp[11];
		my $j=1;  ## pos on transcript
		for(my $i=$sp[9]-1;;$i--){
			last if $i<0;
#			my $j=1;  ## pos on transcript
			for(my $k=$sp[1]+$point[$i]+$leng[$i];;$k--){
				last if $k==$sp[1]+$point[$i];
				$convert{$sp[3]}{$sp[0]}{$k}=$j;
#				print STDERR "$sp[3]\t$sp[0]\t-\t$k\t$j\n";
				$j++;
			}
		}
	}
}


open IN2,$ARGV[0] or die $!;      # homer annotated file
open OUT,">$ARGV[1]" or die $!;
while(<IN2>){
	chomp;
	my @sp=split /\t/;
	next if !/chr/;
	if( $sp[7]=~ /\((\w+),\s+exon\s+\d+\s+of\s+\d+\)/ || $sp[7]=~/TTS\s+\((\S+)\)/ || $sp[7]=~ /promoter-TSS\s+\((\S+)\)/ )  {
		my $id=$1;
		my $mid="NA";
		my $left="NA";
		my $right="NA";
		if (!exists $strand{$id} ) {print OUT "no_refseq\tNA\tNA\tNA\tNA\t$_\n";next;}
		my $tmp=int(($sp[2]+$sp[3])/2);
		$left=$convert{$id}{$sp[1]}{$sp[2]} if exists $convert{$id}{$sp[1]}{$sp[2]};
		$right=$convert{$id}{$sp[1]}{$sp[3]} if exists $convert{$id}{$sp[1]}{$sp[3]};
		$mid=$convert{$id}{$sp[1]}{$tmp} if exists $convert{$id}{$sp[1]}{$tmp};
		print OUT "$id\t$left\t$mid\t$right\t$strand{$id}\t$_\n" if $strand{$id} eq "+";
		print OUT "$id\t$right\t$mid\t$left\t$strand{$id}\t$_\n" if $strand{$id} eq "-";
		next;
	}
	if($sp[7]=~ /Intergenic/){
		print OUT "Intergenic\tNA\tNA\tNA\tNA\t$_\n";
		next;
	}
	if($sp[7]=~ /intron/){
		print OUT "intron\tNA\tNA\tNA\tNA\t$_\n";
		next;
	}
	print OUT "NA\tNA\tNA\tNA\tNA\t$_\n";
}

			
			
			
			



