#! /usr/bin/perl -w
use strict;

##### To calculate the average depth in sliding windows, according to the mpileup file
die "usage: perl $0 mpileup.xls .bam/sam window_length slide_pace output\n" unless @ARGV==5;

my $win=$ARGV[2];   ## the length of the window
my $pace=$ARGV[3];   ## the sliding pace

open IN,"<$ARGV[0]" or die $!;    ## mpileup output file
open IN1,"samtools view -h $ARGV[1]|" or die $!;   ## The corresponding sam/bam file, to retrive the length of each gene/chr
open OUT,">$ARGV[-1]" or die $!;   

sub mid{    ## build the midian func
  my @list = sort{$a<=>$b} @_;
  my $count = @list;
  if( $count == 0 )
    {
      return undef;
    }
  if(($count%2)==1){
    return $list[int(($count-1)/2)];
  }
  elsif(($count%2)==0){
    return ($list[int(($count-1)/2)]+$list[int(($count)/2)])/2;
  }
}

my %base;
while(<IN>){
   chomp;
   my @sp=split /\s+/;
   $base{$sp[0]}{$sp[1]}=$sp[3];
}
close IN;



my %length;
while(<IN1>){
   chomp;
   last if !/@/;
   if(/SN:(\S+)/){
      my $id=$1;
      if(/LN:(\d+)/){
         $length{$id}=$1;
      }
   }
}
close IN1;

print OUT "geneid\twin_start\twin_stop\tavg_depth\tnormalized\n";
foreach my $gene(sort keys %base){
   next if $length{$gene}<=$win;
   my @gene_base;
   for(my $i=1;;$i++){
      last if $i>$length{$gene};
      $base{$gene}{$i}=0 if !exists $base{$gene}{$i};
      $gene_base[$i-1]=$base{$gene}{$i};
   }
   my $gene_midian= mid(@gene_base);
   print STDERR "$gene\t$gene_midian\n";
   $gene_midian=1 if $gene_midian==0; 
   for(my $i=1;;$i+=$pace){
      my $sum=0;
      my $tmp=$i+$win-1;
      if($tmp>=$length{$gene}){
         my $tmp2=$length{$gene}-$win+1;
         for(my $j=$tmp2;;$j++){
            last if $j==$length{$gene}+1;
            $sum+=$base{$gene}{$j};
         }
         my $avg=$sum/$win;
         my $norm=$avg/$gene_midian;
         print OUT "$gene\t$tmp2\t$length{$gene}\t$avg\t$norm\n";
         last;  
      }
      for(my $j=$i;;$j++){
          last if $j==$i+$win;
          $sum+=$base{$gene}{$j};
      }
      my $avg=$sum/$win;
      my $norm=$avg/$gene_midian;
      print OUT "$gene\t$i\t$tmp\t$avg\t$norm\n";
   }
}
close OUT;
