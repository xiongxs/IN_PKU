#!/usr/bin/perl
#===========================================================
#    File Name:  CallModC.pl
#      Version:  1.0
#       Author:  tanyuexi
#      Contact:  tanyuexi@gmail.com
#         Date:  Mon Jan 28 22:11:45 CST 2013
#  Discription:  This script is used to
# Modification:  <name> <date> <change>
#                none
#===========================================================

use strict;
use PerlIO::gzip;

#-----------------------------------------------------------
my $usage = "Usage: perl $0 sample sample_non-conversion_rate.xls modCytSplt_out.gz [--has_C] >Out
Output format: my (\$chr,\$pos,\$strand,\$seq,\$cSum,\$ctSum,\$pvl) = split;\n";
die $usage if @ARGV<3;
my $hasC = ($ARGV[-1] eq "--has_C");
my ($sample,$list,$fin) = @ARGV;
chomp(my $nonconvr = `grep $sample $list | awk '{print \$2}'`);
die "ERROR: No $sample in $list.\n" unless $nonconvr;
open I, "<:gzip", $fin or die $!;
open O, "|R --vanilla --slave" or die $!;
#-----------------------------------------------------------
while(<I>){
   my ($chr,$pos,$strand,$seq,$cSum,$ctSum,$cSumOp,$ctSumOp,$dbSnp) = split;
   next if $dbSnp ne "." || ($hasC && $cSum==0);
   print O <<__CODE__;
cat("$chr","$pos","$strand","$seq",$cSum,$ctSum,sum(dbinom($cSum:$ctSum,$ctSum,$nonconvr)),"\n", fill=FALSE, append=FALSE, sep="\t", file="")
__CODE__
}
print O "quit(save=\"no\")\n";
close O;
#EOF
