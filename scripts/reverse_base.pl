#! /usr/bin/perl -w
use strict;

#open IN,"<$ARGV[0]" or die $!;
#open OUT,">$ARGV[1]" or die $!;

#while(<IN>){

my $in=$ARGV[0];
while($in=~ /(\w)$/){
	my $tmp=$1;
	if($tmp=~ /T|t/){print "A";}
	if($tmp=~ /C|c/){print "G";}
	if($tmp=~ /G|g/){print "C";}
	if($tmp=~ /A|a/){print "T";}
	my $len=length $in;
	$in=substr($in,0,$len-1);
}
print "\n";
