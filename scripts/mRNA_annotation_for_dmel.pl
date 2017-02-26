#! /usr/bin/perl -w
use strict;

open IN1,"<$ARGV[0]" or die $!;  ## The gtf file
open IN2,"<$ARGV[1]" or die $!;  ## The psiU site file

open OUT,">$ARGV[2]" or die $!;  ## The gtf file generated for mRNAs
open OUT2,">$ARGV[3]" or die $!;  ## The annotated results

my %mRNA;
while(<IN1>){
	chomp;
	my @sp=split /\s+/;
	my $id;
	if(/(FBtr\w+)/){
		$id=$1;
	}
	next if $sp[2]=~ /exon/;
	next if $sp[2]=~ /_codon/;
	my $leng=$sp[4]-$sp[3]+1;
	if($sp[6] eq "+"){$mRNA{1}{$id}{$sp[2]}.="$leng---";}
	if($sp[6] eq "-"){$mRNA{2}{$id}{$sp[2]}.="$leng---";}
}
close IN1;

my %pos;
print OUT "ID\tCDS-start\tCDS-end\ttotal-length\n";
foreach my $key(sort keys %{$mRNA{1}}){
	if(!exists $mRNA{1}{$key}{"5UTR"}){$mRNA{1}{$key}{"5UTR"}=0;}
	my @utr5=split /---/, $mRNA{1}{$key}{"5UTR"};
	my $leng_utr5=0;
	for(my $i=0;;$i++){
		last if !defined $utr5[$i];
		$leng_utr5+=$utr5[$i];
	}
	my $leng_cds=0;
	my @cds=split /---/, $mRNA{1}{$key}{CDS};
	for(my $i=0;;$i++){
		last if !defined $cds[$i];
		$leng_cds+=$cds[$i];
	}
	my $leng_utr3=0;
	if(!exists $mRNA{1}{$key}{"3UTR"}){$mRNA{1}{$key}{"3UTR"}=0;}
	my @utr3=split /---/, $mRNA{1}{$key}{"3UTR"};
	for(my $i=0;;$i++){
		last if !defined $utr3[$i];
        $leng_utr3+=$utr3[$i];
	}
	$pos{$key}{start}=$leng_utr5+1;
	$pos{$key}{end}=$leng_utr5+$leng_cds;
	my $total=$leng_utr5+$leng_cds+3+$leng_utr3;
	print OUT "$key\t$pos{$key}{start}\t$pos{$key}{end}\t$total\n";
}

foreach my $key(sort keys %{$mRNA{2}}){
	if(!exists $mRNA{2}{$key}{"5UTR"}){$mRNA{2}{$key}{"5UTR"}=0;}
	my @utr5=split /---/, $mRNA{2}{$key}{"5UTR"};
	my $leng_utr5=0;
	for(my $i=-1;;$i--){
		last if !defined $utr5[$i];
		$leng_utr5+=$utr5[$i];
	}
	my $leng_cds=0;
	my @cds=split /---/, $mRNA{2}{$key}{CDS};
	for(my $i=-1;;$i--){
		last if !defined $cds[$i];
		$leng_cds+=$cds[$i];
	}
	my $leng_utr3=0;
	if(!exists $mRNA{2}{$key}{"3UTR"}){$mRNA{2}{$key}{"3UTR"}=0;}
	my @utr3=split /---/, $mRNA{2}{$key}{"3UTR"};
	for(my $i=-1;;$i--){
		last if !defined $utr3[$i];
        $leng_utr3+=$utr3[$i];
	}
	$pos{$key}{start}=$leng_utr5+1;
	$pos{$key}{end}=$leng_utr5+$leng_cds;  ## not include stop codon
	my $total=$leng_utr5+$leng_cds+3+$leng_utr3;
	print OUT "$key\t$pos{$key}{start}\t$pos{$key}{end}\t$total\n";
}

while(<IN2>){
	chomp;
	next if !/mRNA/;
	my @sp=split /\s+/;
	if($pos{$sp[1]}{start}>$sp[2]){print OUT2 "5'UTR\t$_\n";}
	if($pos{$sp[1]}{start}<=$sp[2] && $pos{$sp[1]}{start}+3>$sp[2]){print OUT2 "start-codon\t$_\n";}
	if($pos{$sp[1]}{end}>=$sp[2] && $pos{$sp[1]}{start}+3<=$sp[2]){print OUT2 "CDS\t$_\n";}
	if($pos{$sp[1]}{end}<$sp[2] && $pos{$sp[1]}{end}+3>=$sp[2]){print OUT2 "stop-codon\t$_\n";}
	if($pos{$sp[1]}{end}+3<$sp[2]){print OUT2 "3'UTR\t$_\n";}
}		
