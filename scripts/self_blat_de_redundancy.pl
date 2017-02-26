#! /usr/bin/perl -w
use strict;

##  Edited to remove the redundancy by blat oneself; remove the highly similar sequnce, and keep the longest item
### filters:
# 1. select the longest one
# 2. mis-match <= 2
# 3. mapped length should be differ less than 2 than the shorter one

die "Usage: perl $0 self_blat.psl output\n" unless @ARGV==2;
open IN,"<$ARGV[0]" or die $!;
open OUT,">$ARGV[1]" or die $!;

my %gene;
my %redun;
while(<IN>){
	chomp;
	next if !/^\d/;
	my @sp=split /\s+/;
	next if exists $redun{$sp[9]};
	if(exists $gene{$sp[9]}){
		next if $sp[1]>2;
		next if $sp[9] eq $sp[13];
		if($sp[0]<$sp[10]-2 && $sp[0]<$sp[14]-2){next;}
		$gene{$sp[9]}.="$sp[13]---$sp[14]\t";
		$redun{$sp[13]}=1;
#		if(/FBtr0085086/){print "$sp[9]\t$sp[13]\n";}
	}
	if(!exists $gene{$sp[9]}){
		$gene{$sp[9]}.="$sp[9]---$sp[10]\t";
		next if $sp[1]>2;
		next if $sp[9] eq $sp[13];
		if($sp[0]<$sp[10]-2 && $sp[0]<$sp[14]-2){next;}
		$gene{$sp[9]}.="$sp[13]---$sp[14]\t";
		$redun{$sp[13]}=1;
	}
}
close IN;

foreach my $key(sort keys %gene){
	my @sp=split /\s+/, $gene{$key};
	my $tmp=$key; my $longest;
	for(my $i=0;;$i++){
		last if !defined $sp[$i];
		my @a=split /---/, $sp[$i];
		print "###### $a[0]\t$a[1]\n";
		if($i==0){$longest=$a[1];next;}
		next if $a[1]<=$longest;
		$tmp=$a[0]; $longest=$a[1];
	}
	print OUT "$tmp\n";
}


		
