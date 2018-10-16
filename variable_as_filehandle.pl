#! /usr/bin/perl
use strict;
use warnings;
#use FileHandle;

my @tmp= qw/illu correct illu.fwd.chr1/;

my %fh;
foreach my $tmp(@tmp){
     open $fh{$tmp},"$tmp.csv" or die $!;
}

open OUT,">test.txt" or die $!;
for(my $i=0;;$i++){
     last if $i==1000;
     foreach my $tmp(@tmp){
          my $h=$fh{$tmp};
          chomp(my $line=<$h>);
          print OUT "$tmp\t$line\n";
     }
}
