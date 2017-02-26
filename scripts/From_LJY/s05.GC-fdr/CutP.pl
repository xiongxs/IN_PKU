#!/usr/bin/perl
#===========================================================
#    File Name:  CutP.benj.pl
#      Version:  1.0
#       Author:  tanyuexi
#      Contact:  tanyuexi@gmail.com
#         Date:  Tue Dec 18 16:30:21 CST 2012
#  Discription:  This script is used to
# Modification:  <name> <date> <change>
#                none
#===========================================================

use strict;

#-----------------------------------------------------------
chomp(my $bn=`basename $0`);
my $usage = "Usage: perl $bn FDR Info >Cut-off\n";
die $usage if @ARGV<2;
my $fdr = shift @ARGV;
while(<>){
   /FDR=(.+?),/;
   next unless $1==$fdr;
   printf("%.2e\n",$1) if /Cut-off=(.+?)\s/;
}
#EOF
