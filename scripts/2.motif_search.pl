#! /usr/bin/perl -w
use strict;

my $usage="Usage: perl $0 <motif_file> <fasta_file> <output> <out.log>\n";
die $usage unless @ARGV==4;

## Edited to manaully search the inputted motif
## File Format
#
# motif_id	()()()()..        The () include all the possible base in the site

open IN,"<$ARGV[0]" or die $!;   ## The motif file
my $total=0;

my %motif;
while(<IN>){
	chomp;
	my @sp=split /\s+/;
	my @site=($sp[1]=~ /\((\w+)\)/g);
	for(my $i=0;;$i++){
		last if !defined $site[$i];
		$motif{$sp[0]}{$i}="[$site[$i]]";
	}
#	print $motif{$sp[0]}{$i}
}
close IN;

open IN1,"<$ARGV[1]" or die $!;   ## The fasta file of flanking seq of psiU
open OUT,">$ARGV[2]" or die $!;   ## The detailed information for each motif
open OUT1,">$ARGV[3]" or die $!;  ## Information summarized
print OUT "protein_id\tmotif_type\ttranscript_id\tmotif\tloc\n";
print OUT1 "motif_type\tnumber\tpercent\n";

my %retri_motif;
while(<IN1>){
	chomp;
	$total++;
	my $line=$_;
	my $id=$1 if $line=~ />(\S+)/;
#	print "$id\n";
	chomp (my $line2=<IN1>);
	my $seq= uc($line2);
	foreach my $key (sort keys %motif){
		my $moti="";
		for(my $i=0;;$i++){
			last if !exists $motif{$key}{$i};
			$moti.=$motif{$key}{$i};
		}
#		print "$moti\n";
		while($seq=~ m/($moti)/g){
			my $a= pos($seq);
			my $retri=$1;
			$retri_motif{$key}{$id}{$a}="$key\t$moti\t$id\t$retri\t$a";
			$seq=~ s/$moti/NNNN/;     ## substitute the 4 bases
		}
	}
}

foreach my $moti(sort keys %retri_motif){
	my $i=0;
	print OUT "\n<====== protein $moti ======>\n";
	foreach my $id(sort keys %{$retri_motif{$moti}}){
		$i++;
		foreach my $pos(sort keys %{$retri_motif{$moti}{$id}}){
#			$i++;
			print OUT "$retri_motif{$moti}{$id}{$pos}\n";
		}
	}
	my $perc=$i/$total;
	print OUT1 "$moti\t$i\t$perc\n"; 
}
