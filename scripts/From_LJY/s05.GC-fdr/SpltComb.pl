#!/usr/bin/perl
#===========================================================
#    File Name:  SpltComb.pl
#      Version:  1.0
#       Author:  tanyuexi
#      Contact:  tanyuexi@gmail.com
#         Date:  Wed Oct  3 19:31:26 CST 2012
#  Discription:  This script is used to
# Modification:  <name> <date> <change>
#                none
#===========================================================

use strict;

#-----------------------------------------------------------
my $usage = "Usage: perl $0 in.CTX outPrefix(STR.gz) >Info\n";
die $usage if @ARGV<2;
my ($fin,$outpre) = @ARGV;
open I, "< $fin" or die $!;
#-----------------------------------------------------------
my %Comb_Fhi;
my %Comb_Tot;
my @fh;
while(<I>){
   my ($chr,$pos,$strand,$seq,$cSum,$ctSum,$pvl) = split;
   my $line = $_;
   my $comb = $strand;
   if(!exists $Comb_Fhi{$comb}){
      $Comb_Fhi{$comb} = scalar(@fh);
      open $fh[@fh], ">:gzip", "${outpre}$comb.gz" or die $!;
   }
   ++$Comb_Tot{$comb};
   print { $fh[$Comb_Fhi{$comb}] } $line;
}
#-----------------------------------------------------------
#print "Total\t$.\n";
print "${outpre}$_\t$Comb_Tot{$_}\n" for(sort keys %Comb_Tot);
#EOF
