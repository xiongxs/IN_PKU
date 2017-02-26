#! /usr/bin/perl -w
use strict;

##### By Xushen Xiong, edited to trim the raw reads

die "Usage: perl $0 abc.fq abc.trimmed.fq\n" unless @ARGV==2;

open IN,"<$ARGV[0]" or die $!;
open OUT,">$ARGV[1]" or die $!;

my $min_length=20;  ## The min length permitted for the trimmed reads

while(<IN>){
	chomp;
	my $line1=$_;
    chomp(my $line2=<IN>);
	chomp(my $line3=<IN>);
	chomp(my $line4=<IN>);
	my $len_1=length $line2;
	if($line2=~ s/^(AA[A]+)//){
		my $left=length $1;
	    my $tmp=$len_1-$left;
        $line4=substr($line4,$left,$tmp);
    }
    my $len_2=length $line2;
	if($line2=~ s/([A]+AA)$//){
		my $right=length $1;
	    my $tmp=$len_2-$right;
		$line4=substr($line4,0,$tmp);
    }
    my $remain=length $line2;
	next if $remain<$min_length;
    print OUT "$line1\n$line2\n$line3\n$line4\n";
}


