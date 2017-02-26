#!/usr/bin/perl
#===========================================================
#    File Name:  covStrBed.pl
#      Version:  1.0
#       Author:  tanyuexi
#      Contact:  tanyuexi@gmail.com
#         Date:  Tue Nov 27 09:48:08 CST 2012
#  Discription:  This script is used to
# Modification:  <name> <date> <change>
#                none
#===========================================================

use strict;
use PerlIO::gzip;

#-----------------------------------------------------------
my $usage = "Usage: perl $0 In.pileup[.gz] OutPrefix(chr.STR.covMIN.bed) [Min(default:1)] >Out.pileup\n";
die $usage if @ARGV<2;
my ($plp,$out,$min) = @ARGV;
$min ||= 1;
my ($pchr,$pbeg,$pend,$nchr,$nbeg,$nend);
my $opencmd = ($plp=~/\.gz$/)? "<:gzip": "<";
open I, $opencmd, $plp or die $!;
while(<I>){
   print $_;
   my ($c,$p,$b) = (split)[0,1,4];
   if(($b=~tr/.ATCGN/.ATCGN/)>=$min){
      if($c ne $pchr){
         print P "$pchr\t$pbeg\t$pend\n" if defined $pchr;
         close P;
         open P, ">${out}$c.+.cov$min.bed" or die $!;
         $pchr = $c;
         $pbeg = $p - 1;
      }elsif($p!=$pend+1){
         print P "$pchr\t$pbeg\t$pend\n";
         $pbeg = $p - 1;
      }
      $pend = $p;
   }
   if(($b=~tr/,atcgn/,atcgn/)>=$min){
      if($c ne $nchr){
         print N "$nchr\t$nbeg\t$nend\n" if defined $nchr;
         close N;
         open N, ">${out}$c.-.cov$min.bed" or die $!;
         $nchr = $c;
         $nbeg = $p - 1;
      }elsif($p!=$nend+1){
         print N "$nchr\t$nbeg\t$nend\n";
         $nbeg = $p - 1;
      }
      $nend = $p;
   }
}
print P "$pchr\t$pbeg\t$pend\n";
print N "$nchr\t$nbeg\t$nend\n";
#EOF
