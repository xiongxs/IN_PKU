#!/usr/bin/perl
#===========================================================
#    File Name:  modCytSplt.pl
#      Version:  1.0
#       Author:  tanyuexi
#      Contact:  tanyuexi@gmail.com
#         Date:  Fri Feb 22 14:49:13 CST 2013
#  Discription:  This script is used to
# Modification:  <name> <date> <change>
#                none
#===========================================================

use strict;
use PerlIO::gzip;

#-----------------------------------------------------------
my $usage = "Usage: perl $0 [dbSNP:chr_pos_ref_snp.gz] ref.fa in.pileup[.gz] outPre(GC.gz|GHC.gz|HHC.gz|NNC.gz) >pileup
Output format: my (\$chr,\$pos,\$strand,\$seq,\$cSum,\$ctSum,\$cSumOp,\$ctSumOp,\$dbSnp);\n";
die $usage if @ARGV<3;
my $dbsnp = 0;
$dbsnp = shift @ARGV if @ARGV == 4;
my ($ref,$pileup,$outpre) = @ARGV;
my %Chr_Seq;
open R, "< $ref" or die $!;
open I, ($pileup=~/\.gz$/)? "<:gzip": "<", $pileup or die $!;
my @out;
my @context = ("GC","GHC","HHC","NNC");
open $out[0], ">:gzip", "${outpre}GC.gz" or die $!;
open $out[1], ">:gzip", "${outpre}GHC.gz" or die $!;
open $out[2], ">:gzip", "${outpre}HHC.gz" or die $!;
open $out[3], ">:gzip", "${outpre}NNC.gz" or die $!;
#-----------------------------------------------------------
#   Read dbSNP
my %db_inf;
if($dbsnp){
   open S, "<:gzip", $dbsnp or die $!;
   while(<S>){
      my ($chr,$pos,$ref,$snp) = split;
      $db_inf{"$chr-$pos"} = "$ref>$snp";
   }
   close S;
}
#-----------------------------------------------------------
#   Read reference FASTA
$/ = ">";
<R>;
$/ = "\n";
while(<R>){
   chomp(my $chrtmp = $_);
   $/ = ">";
   $_ = <R>;
   $/ = "\n";
   chop($_);
   $_ =~ s/\n//g;
   $_ = uc $_;
   $Chr_Seq{$chrtmp} = $_;
}
close R;
#-----------------------------------------------------------
#   Read pileup
while(<I>){
   print $_;
   my ($chr,$pos,$ref,undef,$base) = split;
   my ($strand,$ctSum,$cSum,$tSum,$ctSumOp,$cSumOp,$tSumOp,$dbSnp);
   warn "WARN: No such chromosome $chr (line $. in $pileup)\n" and next unless defined $Chr_Seq{$chr};
   $ref = substr($Chr_Seq{$chr},$pos-1,1) if $ref eq "N";
   if($ref =~ /C|c/){
      $strand = "+";
   }elsif($ref =~ /G|g/){
      $strand = "-";
   }else{
      next;
   }
   my $i;
   my $tmp;
   if($strand eq "+"){
      $tmp = substr($Chr_Seq{$chr},$pos-3,2);
      $cSum = ($base =~ tr/././);
      $tSum = ($base =~ tr/T/T/);
      $cSumOp = ($base =~ tr/,/,/);
      $tSumOp = ($base =~ tr/t/t/);
   }else{
      $tmp = join("",reverse(split //,substr($Chr_Seq{$chr},$pos,2)));
      $tmp =~ tr/ATCG/TAGC/;
      $cSum = ($base =~ tr/,/,/);
      $tSum = ($base =~ tr/a/a/);
      $cSumOp = ($base =~ tr/././);
      $tSumOp = ($base =~ tr/A/A/);
   }
   if($tmp =~ /.G/){
      $i = 0;
   }elsif($tmp =~ /G[ATC]/){
      $i = 1;
   }elsif($tmp =~ /[ATC]{2}/){
      $i = 2;
   }else{
      $i = 3;
   }
   $ctSum = $cSum + $tSum;
   next if $ctSum == 0;
   $ctSumOp = $cSumOp + $tSumOp;
   $dbSnp = exists $db_inf{"$chr-$pos"}? $db_inf{"$chr-$pos"}: ".";
   print { $out[$i] } (join("\t",$chr,$pos,$strand,"$tmp\C",$cSum,$ctSum,$cSumOp,$ctSumOp,$dbSnp),"\n");
}
close $out[$_] for(0 .. $#out);
#EOF
