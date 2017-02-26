#!/usr/bin/perl
#===========================================================
#    File Name:  SamStat.pl
#      Version:  1.0
#       Author:  tanyuexi
#      Contact:  tanyuexi@gmail.com
#         Date:  Sun Apr  1 17:45:35 CST 2012
#  Discription:  This script is used to
# Modification:  <name> <date> <change>
#                none
#===========================================================

use strict;
use PerlIO::gzip;
#-----------------------------------------------------------

my $usage = "Usage: $0 File(.sam) out.log [--in_bam] [--uniq|--not_uniq=RegEx(default:--uniq=\'XT:A:U\'forBWA.Tips:--not_uniq=\'XS:i:\'forBowtie)] >SAM\n
Flag Description
0x1 template having multiple segments in sequencing
0x2 each segment properly aligned according to the aligner
0x4 segment unmapped
0x8 next segment in the template unmapped
0x10 SEQ being reverse complemented
0x20 SEQ of the next segment in the template being reversed
0x40 the first segment in the template
0x80 the last segment in the template
0x100 secondary alignment
0x200 not passing quality controls
0x400 PCR or optical duplicate\n";
die $usage if @ARGV<2;
my $samtools = "samtools";
my $infile = shift @ARGV;
my $logfile = shift @ARGV;
my $bam = 0;
my $uyes = 1;
my $umark = "XT:A:U";
for(@ARGV){
   $bam = 1 if $_ eq "--in_bam";
   if(/^--uniq='?"?(\S+?)'?"?$/){
      $umark = $1;
   }elsif(/^--not_uniq='?"?(\S+?)'?"?$/){
      $umark = $1;
      $uyes = 0;
   }
}
my %Insz_Read;
my %Code_Read;
$Code_Read{$_} = 0 for(0 .. 10);
my ($totr,$alnr,$totb,$alnb,$misb,$unqr,$unqb,$dupr) = (0) x 8;
my $viewcmd = $bam? "$samtools view -h $infile |": "< $infile";
open I,$viewcmd or die $!;
open L, "> $logfile" or die $!;
#-----------------------------------------------------------
while(<I>){
   if(/^\@/o){
      print $_;
   }else{
      die "ERROR: Missing SAM header. Try \'--in_bam\'\n" if $.==1;
      last;
   }
}
do{
   print $_;
   ++$totr;
   my @f = split;
   my ($flag,$seqid,$beg,$cigar,$insz,$read) = @f[1,2,3,5,8,9];
   my @bit = split //, sprintf("%011b",$flag);
   my ($Dup0,$Unmap8) = @bit[0,8];
   my $XX = "@f[11 .. $#f]";
   $read = length($read);
   $totb += $read;
   ++$Insz_Read{$insz} if $insz>0;
   $misb += $1 if $XX=~/XM:i:(\d+)/o;
   my $XC = ($XX=~/XC:i:(\d+)/o)? $1: &high_qual($cigar);
   ++$dupr if $Dup0;
   $bit[$_] and ++$Code_Read{$_} for(0 .. 10);
   if(!$Unmap8){
      ++$alnr;
      $alnb += $XC;
      if(($uyes && $XX=~/$umark/o) || (!$uyes && $XX!~/$umark/o)){
         ++$unqr;
         $unqb += $XC;
      }
   }
}while(<I>);
close I;
#-----------------------------------------------------------
my ($totinsz,$inszread);
for(keys %Insz_Read){
   $totinsz += $_ * $Insz_Read{$_};
   $inszread += $Insz_Read{$_};
}
my $meaninsz = $inszread? sprintf("%d",$totinsz/$inszread): 0;
my $modeinsz = (sort {$Insz_Read{$b} <=> $Insz_Read{$a}} keys %Insz_Read)[0];
#-----------------------------------------------------------
my $c = 0;
print L "C",++$c,":Total_base\t";
print L "C",++$c,":Aligned_base\t";
print L "C",++$c,":Unique_base\t";
print L "C",++$c,":Mismatch_base\t";
print L "C",++$c,":Total_read\t";
print L "C",++$c,":Aligned_read\t";
print L "C",++$c,":Unique_read\t";
print L "C",++$c,":Duplicate_read\t";
print L "C",++$c,sprintf(":0x%x\t",2**$_) for(0 .. 10);
print L "C",++$c,":Mean_insert_size\t";
print L "C",++$c,":Mode_insert_size\n";
print L "$totb\t$alnb\t$unqb\t$misb\t$totr\t$alnr\t$unqr\t$dupr\t";
print L "$Code_Read{$_}\t" for(reverse(0 .. 10));
print L "$meaninsz\t$modeinsz\n";
print L "Insert_size\tRead_pair\n";
print L "$_\t$Insz_Read{$_}\n" for(sort {$a <=> $b} keys %Insz_Read);
#-----------------------------------------------------------
sub high_qual{ # CIGAR
   my $sum;
   for($_[0]=~/(\d+)M|(\d+)D/g){
      $sum += $_;
   }
   return $sum;
}
#EOF
