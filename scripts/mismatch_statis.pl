#! /usr/bin/perl -w
use strict;

## By Xiongxs, Edited to calculate the mismatch rate of all possible mismatch

open IN,$ARGV[0] or die $!;    ## The mpileup file
open OUT,">$ARGV[1]" or die $!;   ## The output

my %mis;
while(<IN>){
	chomp;
	my @sp=split /\s+/;
	next if /mpileup/;
	$sp[2]=uc($sp[2]);
	while($sp[4]=~ s/([ATCGatcgNn])//){
		my $tmp=uc($1);
#		next if $tmp eq $sp[2];
	    my $lig="$sp[2]2$tmp";
		$mis{$lig}+=1;
    }
}

my $sum=0;
foreach my $key(sort keys %mis){
	$sum+=$mis{$key};
}

foreach my $key(sort keys %mis){
	my $pec=int($mis{$key}/$sum*10000)/100;
	print OUT "$key\t$mis{$key}\t$pec\n";
}





