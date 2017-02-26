#! /usr/bin/perl -w
use strict;

######### Edited by Xushen, to calculate the signal density like Histone modification, DNase, MNase using wig file 

##### wig file format
##### chr	start	end	density
##### chr1 25450 25475 13.88

my $win=1000;    ## 1k upstream and 1k downstream
my $bin=20;    ## the bin for signal plot

open IN,$ARGV[0] or die $!;   #### The wig file
open IN2,$ARGV[1] or die $!;   ### The peak/pos file
open OUT,">$ARGV[2]" or die $!;   ## The output file

my %flag;
my %site;
while(<IN2>){
	chomp;
	my @sp=split /\s+/;
	$site{$sp[0]}{$sp[1]}=1;
	for(my $i=$sp[1]-$win;;$i++){
		$flag{$sp[0]}{$i}=1;
		last if $i==$sp[1]+$win;
	}
}
close IN2;

my %signal;
while(<IN>){
	chomp;
	my @sp=split /\s+/;
	if(!exists $flag{$sp[0]}{$sp[1]} && !exists $flag{$sp[0]}{$sp[2]}){next;}
	for(my $i=$sp[1];;$i++){
		$signal{$sp[0]}{$i}=$sp[3];
		last if $i==$sp[2];
	}
}
close IN;

my %plot;
my $num=0;    ## the number of total sites
foreach my $chr(sort keys %site){
	foreach my $pos(sort {$a<=>$b} keys %{$site{$chr}}){
		$num++;
		print STDERR "##############$chr\t$pos\n";
		for(my $i=$pos-$win;;$i++){
			last if $i==$pos+$win;
			$signal{$chr}{$i}=0 if !exists $signal{$chr}{$i};
			my $test=$i-$pos;
			print STDERR "$chr\t$i\t$test\t$signal{$chr}{$i}\n";
			my $tmp=int(($i-$pos+$win)/$bin);
			$plot{$tmp}+=$signal{$chr}{$i};
		}
	}
}

print STDERR "$num\n";
foreach my $seg(sort {$a<=>$b} keys %plot){
	my $tmp=$plot{$seg}/($num*$bin);
	my $tmp2=$seg+0.5-$win/$bin;
	print OUT "$tmp2\t$tmp\n";
}





